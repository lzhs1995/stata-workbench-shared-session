"use strict";

const crypto = require("crypto");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { scanDoReferences } = require("./stata_do_references");

function slash(value) {
  return value ? String(value).replace(/\\/g, "/").replace(/\/$/, "") : null;
}

function mappingError(detail) {
  return Object.assign(new Error("SOURCE_PATH_MAPPINGS_INVALID: " + detail), { code: "SOURCE_PATH_MAPPINGS_INVALID" });
}

function normalizeMappingPath(value) {
  if (typeof value !== "string" || /[\x00-\x1f"`$]/.test(value)) throw mappingError("from/to must be literal absolute paths without quotes, controls or macros");
  let normalized = value.replace(/\\/g, "/");
  const unc = normalized.startsWith("//");
  normalized = (unc ? "//" : "") + (unc ? normalized.slice(2) : normalized).replace(/\/{2,}/g, "/");
  if (!/^(?:[A-Za-z]:\/|\/)/.test(normalized) || normalized.split("/").some(part => part === "." || part === "..")) {
    throw mappingError("from/to must be absolute paths without dot segments");
  }
  if (unc && !/^\/\/[^/]+\/[^/]+/.test(normalized)) throw mappingError("UNC paths need a server and share");
  if (normalized !== "/" && !/^[A-Za-z]:\/$/.test(normalized)) normalized = normalized.replace(/\/$/, "");
  return normalized;
}

function normalizeSourcePathMappings(value = []) {
  if (!Array.isArray(value)) throw mappingError("expected an array of {from,to}");
  const seen = new Set();
  return value.map((entry, index) => {
    if (!entry || typeof entry !== "object" || Array.isArray(entry)) throw mappingError("each mapping needs from/to");
    const from = normalizeMappingPath(entry.from), to = normalizeMappingPath(entry.to);
    const windows = /^[A-Za-z]:\/|^\/\//.test(from);
    const key = windows ? from.toLowerCase() : from;
    if (seen.has(key)) throw mappingError("duplicate source prefix");
    seen.add(key);
    return { from, to, windows, index };
  }).sort((a, b) => b.from.length - a.from.length || a.index - b.index);
}

function rewriteSourcePaths(source, mappings) {
  if (!mappings.length) return { code: String(source), count: 0 };
  let count = 0;
  // Map complete literal path tokens, not substrings in other accounts, sibling
  // directories or prose. Compound quotes keep their surrounding backtick/' .
  const code = String(source).replace(/"[^"\r\n]*"|[^\s"',;()]+/g, token => {
    const quoted = token.startsWith('"'), value = quoted ? token.slice(1, -1) : token;
    const normalized = value.replace(/\\/g, "/");
    for (const mapping of mappings) {
      const current = mapping.windows ? normalized.toLowerCase() : normalized;
      const from = mapping.windows ? mapping.from.toLowerCase() : mapping.from;
      if (current !== from && !current.startsWith(from.endsWith("/") ? from : from + "/")) continue;
      const suffix = normalized.slice(mapping.from.length).replace(/^\/+/, "");
      const replaced = mapping.to + (suffix ? (mapping.to.endsWith("/") ? "" : "/") + suffix : "");
      if (replaced !== value) count++;
      // An unquoted input may map into a path containing spaces. Quote the
      // replacement instead of silently splitting it into Stata arguments.
      return quoted || /[\s,;()']/.test(replaced) ? '"' + replaced + '"' : replaced;
    }
    return token;
  });
  return { code, count };
}

function rewriteQuotedPathSeparators(source) {
  let count = 0;
  const code = String(source).replace(/"([^"\r\n]*)"/g, (quoted, inner) => {
    const pathLike = /[A-Za-z]:[\\/]/.test(inner) ||
      /(?:\$\{[A-Za-z_][A-Za-z0-9_]*\}|\$[A-Za-z_][A-Za-z0-9_]*)\\/.test(inner) ||
      /\/Users\//.test(inner);
    if (!pathLike) return quoted;
    const replaced = inner.replace(/\\(?=[^\s"'\\])/g, () => {
      count += 1;
      return "/";
    });
    return `"${replaced}"`;
  });
  return { code, count };
}

function protectDynamicGraphNames(source) {
  const input = String(source);
  const macroName = `__ws_nopt_${sha256(Buffer.from(input)).slice(0, 8)}`;
  let count = 0;
  let code = input.replace(
    /\bname\((?=[^)\r\n]*`[^)\r\n]*')/g,
    () => {
      count += 1;
      return "`" + macroName + "'(";
    },
  );
  if (count > 0) {
    code = `local ${macroName} name\n${code}\ncapture macro drop ${macroName}\n`;
  }
  return { code, count, macroName: count > 0 ? macroName : null };
}

function ensurePaginationOff(source) {
  const input = String(source == null ? "" : source);
  if (!input.trim()) return { code: input, applied: false };
  if (/^\s*(?:capture\s+)?set\s+more\s+off(?:\s*(?:\/\/[^\r\n]*)?)?(?:\r?\n|$)/i.test(input)) {
    return { code: input, applied: false };
  }
  return { code: `set more off\n${input}`, applied: true };
}

function protectTransportLog(source) {
  // codex patch rc.7.10.33: every visible entry point preserves the live transport log.
  let count = 0;
  const code = String(source == null ? "" : source).replace(
    /^\s*(?:capture\s+)?log\s+close\s+_all\s*(?:(?:\/\/|\*)[^\r\n]*)?$/gmi,
    () => {
      count += 1;
      return 'display as text "[Workbench transport guard] skipped log close _all to preserve live Terminal log"';
    },
  );
  return { code, count };
}

function transformSource(source, options = {}) {
  const input = String(source == null ? "" : source);
  const platform = options.platform || process.platform;
  const mappings = normalizeSourcePathMappings(options.sourcePathMappings);
  const diagnostics = {
    platform,
    applied: false,
    bomStripped: false,
    rootRewrites: 0,
    separatorRewrites: 0,
    dynamicGraphNameProtections: 0,
    dynamicGraphNameMacro: null,
    configuredPathMappings: mappings.length,
  };
  const mapped = rewriteSourcePaths(input, mappings);
  let code = mapped.code;
  diagnostics.rootRewrites = mapped.count;
  if (platform === "darwin") {
    if (code.charCodeAt(0) === 0xfeff) {
      code = code.slice(1);
      diagnostics.bomStripped = true;
    }
    const separated = rewriteQuotedPathSeparators(code);
    code = separated.code;
    diagnostics.separatorRewrites = separated.count;
    const graphNames = protectDynamicGraphNames(code);
    code = graphNames.code;
    diagnostics.dynamicGraphNameProtections = graphNames.count;
    diagnostics.dynamicGraphNameMacro = graphNames.macroName;
  }
  const transportLog = options.protectTransportLog
    ? protectTransportLog(code)
    : { code, count: 0 };
  code = transportLog.code;
  diagnostics.transportLogCloseGuards = transportLog.count;
  diagnostics.applied = code !== input;
  return { code, diagnostics };
}

function sha256(buffer) {
  return crypto.createHash("sha256").update(buffer).digest("hex");
}

function makeCompatCopy(sourcePath, options = {}) {
  const original = fs.readFileSync(sourcePath);
  const originalText = original.toString("utf8");
  const transformed = transformSource(original.toString("utf8"), {
    ...options,
    sourcePath,
  });
  let code = transformed.code;
  // Descendants are prepared before the parent's PNG/DOCX conversion. Only
  // execution copies are rewritten, never the author's source files.
  if (options.recursiveReferencedDo && options.referenceState) {
    code = prepareReferences(code, { ...options, sourcePath }, options.referenceState);
  }
  let secondaryTransform = null;
  if (typeof options.transformReferencedCode === "function") {
    const secondary = options.transformReferencedCode(code, {
      platform: options.platform || process.platform,
      sourcePath,
      diagnostics: transformed.diagnostics,
    });
    if (typeof secondary === "string") {
      code = secondary;
    } else if (secondary && typeof secondary.code === "string") {
      code = secondary.code;
      secondaryTransform = secondary.diagnostics || null;
    } else if (secondary != null) {
      throw new Error("transformReferencedCode must return a string or { code, diagnostics }");
    }
  }
  if (code === originalText) {
    return {
      path: sourcePath,
      changed: false,
      diagnostics: { ...transformed.diagnostics, secondaryTransform },
    };
  }
  const tempRoot = fs.mkdtempSync(path.join(options.tempRoot || os.tmpdir(),
    "stata-workbench-compat-"));
  const target = path.join(tempRoot, path.basename(sourcePath));
  fs.writeFileSync(target, code, "utf8");
  const originalAfter = fs.readFileSync(sourcePath);
  if (sha256(original) !== sha256(originalAfter)) {
    throw new Error("source file changed while preparing compatibility copy");
  }
  return {
    path: target,
    changed: true,
    diagnostics: {
      ...transformed.diagnostics,
      applied: true,
      secondaryTransform,
      sourcePath,
      tempPath: target,
      sourceSha256: sha256(original),
      sourceIntact: true,
    },
  };
}

function referenceError(reason, sourcePath) {
  const error = new Error(`${reason}: ${sourcePath}`);
  error.code = "REFERENCED_DO_PREPARATION_FAILED";
  return error;
}

function prepareReferences(source, options, state) {
  const scan = scanDoReferences(source);
  state.unsupported.push(...scan.unsupported.map(item => ({ ...item, sourcePath: options.sourcePath || null })));
  // A dynamic child or a cd anywhere in a file defeats a static cwd inference.
  // Absolute paths are still safe to resolve without guessing Stata's cwd.
  if (scan.changesCwd || scan.unsupported.length) state.cwdUncertain = true;
  const replacements = [];
  for (const ref of scan.refs) {
    if (state.cwdUncertain && !path.isAbsolute(ref.filePath)) {
      if (options.recursiveReferencedDo) throw referenceError("relative DO after uncertain working directory", ref.filePath);
      continue;
    }
    const resolved = path.resolve(options.cwd || process.cwd(), ref.filePath);
    try {
      const canonical = fs.realpathSync(resolved);
      if (!fs.statSync(canonical).isFile()) throw referenceError("DO is not a regular file", resolved);
      if (state.active.has(canonical)) throw referenceError("cyclic DO reference", resolved);
      if (state.active.size >= 16) throw referenceError("DO reference depth exceeds 16", resolved);
      if (++state.visits > 256) throw referenceError("DO reference count exceeds 256", resolved);
      // Bound synchronous reads on the extension-host event loop.
      state.bytes += fs.statSync(canonical).size;
      if (state.bytes > 16 * 1024 * 1024) throw referenceError("DO source budget exceeds 16 MiB", resolved);
      state.active.add(canonical);
      let copy;
      try {
        copy = makeCompatCopy(resolved, { ...options, referenceState: state });
      } finally {
        state.active.delete(canonical);
      }
      if (copy.changed) {
        state.copies.push(copy.diagnostics);
        replacements.push({ ...ref, path: slash(copy.path) });
      }
    } catch (error) {
      // Darwin must not silently run the original after a failed transform.
      if (options.recursiveReferencedDo) throw referenceError(error.message, resolved);
      state.unsupported.push({ sourcePath: resolved, reason: error.message });
    }
  }
  let code = source;
  for (const ref of replacements.reverse()) code = code.slice(0, ref.start) + ref.path + code.slice(ref.end);
  return code;
}

function prepareExecutionCode(source, options = {}) {
  const compatOptions = {
    ...options,
    protectTransportLog: options.protectTransportLog !== false,
  };
  let transformed = transformSource(source, compatOptions);
  const state = { copies: [], unsupported: [], active: new Set(), visits: 0, bytes: 0, cwdUncertain: false };
  const copies = state.copies;
  let code = prepareReferences(transformed.code, compatOptions, state);
  const pagination = ensurePaginationOff(code);
  code = pagination.code;
  transformed = {
    code,
    diagnostics: {
      ...transformed.diagnostics,
      applied: transformed.diagnostics.applied || copies.length > 0 || pagination.applied,
      paginationGuardApplied: pagination.applied,
      referencedDoCopies: copies,
      unresolvedDoReferences: state.unsupported,
      referenceCoverage: state.unsupported.length ? "partial-static" : "literal-do-only",
    },
  };
  return transformed;
}

module.exports = {
  normalizeSourcePathMappings,
  rewriteSourcePaths,
  ensurePaginationOff,
  makeCompatCopy,
  prepareExecutionCode,
  protectDynamicGraphNames,
  protectTransportLog,
  rewriteQuotedPathSeparators,
  transformSource,
};
