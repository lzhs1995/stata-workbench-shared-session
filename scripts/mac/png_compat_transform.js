#!/usr/bin/env node
/**
 * A3/rc.5 Darwin PNG compatibility transformer (sidecar).
 *
 * APPROVED EXCEPTION:
 * - macOS only when applied in production path
 * - temporary execution copy only (never write research .do)
 * - raster graph export (png/jpg/jpeg) -> SVG + /usr/bin/sips via sh helper
 * - putdocx/p_tdocx image -> marker text + post-save OOXML injection helper
 * - macros ($ / ${} / `local') kept as opaque path expressions
 * - unparseable -> PNG_COMPAT_UNSUPPORTED (no native PNG hang fallback)
 *
 * DEV-MAC-PNG-RASTERIZER: SVG+sips is not native Stata pixel identity.
 */
"use strict";

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const RASTER_EXT_RE = /\.(png|jpg|jpeg)\b/i;
const DOCX_COMPAT_MARKER = "DOCX_IMAGE_COMPAT_DARWIN";

function logicalStatements(source) {
  const lines = source.split(/\r?\n/);
  const out = [];
  let buf = "";
  let startLine = 0;
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const cont = /\/\/\/\s*$/.test(raw.replace(/\s+$/, ""));
    const piece = cont ? raw.replace(/\/\/\/\s*$/, " ") : raw;
    if (!buf) startLine = i;
    buf += piece;
    if (!cont) {
      out.push({ text: buf, startLine, endLine: i });
      buf = "";
    } else {
      buf += "\n";
    }
  }
  if (buf) out.push({ text: buf, startLine, endLine: lines.length - 1 });
  return { lines, statements: out };
}

/** Remove // line comments and block comments outside quotes. */
function stripComments(code) {
  let out = "";
  let i = 0;
  let q = null; // " | ' | compound
  while (i < code.length) {
    const c = code[i];
    const n = code[i + 1];

    if (q === "compound") {
      out += c;
      if (c === '"' && n === "'") {
        out += n;
        i += 2;
        q = null;
        continue;
      }
      i++;
      continue;
    }

    if (q) {
      out += c;
      if (c === q && code[i - 1] !== "\\") q = null;
      i++;
      continue;
    }

    // compound open `"
    if (c === "`" && n === '"') {
      out += c + n;
      q = "compound";
      i += 2;
      continue;
    }

    if (c === '"' || c === "'") {
      q = c;
      out += c;
      i++;
      continue;
    }

    // block comment
    if (c === "/" && n === "*") {
      i += 2;
      while (i < code.length && !(code[i] === "*" && code[i + 1] === "/")) i++;
      i = Math.min(i + 2, code.length);
      out += " ";
      continue;
    }

    // line comment
    if (c === "/" && n === "/") break;

    out += c;
    i++;
  }
  return out;
}

function hasDelimitSemicolon(source) {
  return /#delimit\s*;/i.test(source);
}

function isStarFullLineComment(stmt) {
  // Stata full-line comments start with *; never rewrite them (even if text mentions graph export).
  const t = stmt.replace(/\s+/g, " ").trim();
  return t.startsWith("*");
}

/**
 * Parse path token after "graph export": "..." | '...' | `"..."'
 * Macros inside quotes are allowed and kept opaque.
 */
function parsePathToken(rest) {
  const s = rest.trimStart();
  if (!s) return null;

  // compound `" ... "'
  if (s.startsWith('`"')) {
    let i = 2;
    while (i < s.length) {
      if (s[i] === '"' && s[i + 1] === "'") {
        const token = s.slice(0, i + 2);
        return { token, pathInner: s.slice(2, i), kind: "compound", rest: s.slice(i + 2) };
      }
      i++;
    }
    return { unsupported: true, reason: "unclosed_compound_path" };
  }

  if (s[0] === '"') {
    let i = 1;
    while (i < s.length) {
      if (s[i] === "\\" && i + 1 < s.length) {
        i += 2;
        continue;
      }
      if (s[i] === '"') {
        const token = s.slice(0, i + 1);
        return { token, pathInner: s.slice(1, i), kind: "double", rest: s.slice(i + 1) };
      }
      i++;
    }
    return { unsupported: true, reason: "unclosed_double_path" };
  }

  if (s[0] === "'") {
    // Single-quoted path may embed Stata locals `name' — do not treat local's
    // closing apostrophe as the path terminator.
    let i = 1;
    while (i < s.length) {
      if (s[i] === "`") {
        i++;
        while (i < s.length && s[i] !== "'") i++;
        if (i < s.length) i++; // consume local-closing '
        continue;
      }
      if (s[i] === "'") {
        const token = s.slice(0, i + 1);
        return { token, pathInner: s.slice(1, i), kind: "single", rest: s.slice(i + 1) };
      }
      i++;
    }
    return { unsupported: true, reason: "unclosed_single_path" };
  }

  // bare token (no spaces) — rare; allow macros; do not swallow comma into path
  const m = s.match(/^([^\s,]+)(.*)$/);
  if (!m) return null;
  return { token: m[1], pathInner: m[1], kind: "bare", rest: m[2] };
}

function pathInnerToSvg(pathInner) {
  if (/\.(png|jpg|jpeg)$/i.test(pathInner)) {
    return pathInner.replace(/\.(png|jpg|jpeg)$/i, ".__pngcompat__.svg");
  }
  // as(png) without extension: append marker stem
  return pathInner + ".__pngcompat__.svg";
}

function rewrapPath(kind, pathInner) {
  if (kind === "compound") return '`"' + pathInner + "\"'";
  // Keep Stata locals `name' intact inside single quotes (do not backslash apostrophes).
  if (kind === "single") return "'" + pathInner + "'";
  if (kind === "bare") return pathInner;
  // double
  return '"' + pathInner.replace(/"/g, '\\"') + '"';
}

function hasUnsafePathForm(pathInner) {
  // refuse nested compound / unmatched weirdness we cannot rewrite safely
  if (pathInner.includes('`"') || pathInner.includes("\"'")) return true;
  return false;
}

/**
 * Match: [capture|quietly|noisily]* graph export <path> [, opts]
 * Macros in path/name allowed (opaque).
 */
function matchGraphExport(stmt) {
  if (isStarFullLineComment(stmt)) return null;

  const cleaned = stripComments(stmt).replace(/\s+/g, " ").trim();
  if (!cleaned) return null;
  if (!/\bgraph\s+export\b/i.test(cleaned)) return null;

  const head = cleaned.match(/^((?:(?:capture|quietly|noisily)\s+)*)graph\s+export\s+/i);
  if (!head) {
    if (RASTER_EXT_RE.test(cleaned) || /\bas\s*\(\s*(png|jpg|jpeg)\s*\)/i.test(cleaned)) {
      return { unsupported: true, reason: "unparseable_graph_export", statement: cleaned.slice(0, 200) };
    }
    return null;
  }

  const prefix = head[1] || "";
  const after = cleaned.slice(head[0].length);
  const pathTok = parsePathToken(after);
  if (!pathTok) return null;
  if (pathTok.unsupported) {
    return { unsupported: true, reason: pathTok.reason, statement: cleaned.slice(0, 200) };
  }

  let optStr = (pathTok.rest || "").trim();
  if (optStr.startsWith(",")) optStr = optStr.slice(1).trim();

  const asM = optStr.match(/\bas\s*\(\s*(png|jpg|jpeg|svg|pdf)\s*\)/i);
  const asFmt = asM ? asM[1].toLowerCase() : null;
  if (asFmt === "svg" || asFmt === "pdf") return null;

  const isRaster =
    (asFmt && ["png", "jpg", "jpeg"].includes(asFmt)) || RASTER_EXT_RE.test(pathTok.pathInner);
  if (!isRaster) return null;

  if (hasUnsafePathForm(pathTok.pathInner)) {
    return { unsupported: true, reason: "unsafe_path_form", statement: cleaned.slice(0, 200) };
  }

  const widthM = optStr.match(/\bwidth\s*\(\s*(\d+)\s*\)/i);
  const heightM = optStr.match(/\bheight\s*\(\s*(\d+)\s*\)/i);
  // name(...) may contain macros — capture balanced-ish until ) 
  const nameM = optStr.match(/\bname\s*\(\s*([^)]*)\)/i);
  const replace = /\breplace\b/i.test(optStr);

  return {
    unsupported: false,
    prefix,
    quotedPath: pathTok.token,
    pathInner: pathTok.pathInner,
    pathKind: pathTok.kind,
    optStr,
    width: widthM ? parseInt(widthM[1], 10) : 1200,
    height: heightM ? parseInt(heightM[1], 10) : null,
    name: nameM ? nameM[1].trim() : null,
    replace,
    asFmt: asFmt || extOf(pathTok.pathInner),
    statement: cleaned,
  };
}

function extOf(p) {
  const m = String(p).toLowerCase().match(/\.(png|jpg|jpeg)$/);
  return m ? m[1] : "png";
}

function defaultHelperScript() {
  return path.join(__dirname, "png_compat_sips.sh");
}

function defaultDocxHelperScript() {
  return path.join(__dirname, "docx_image_inject.py");
}

function matchDocumentImage(stmt) {
  if (isStarFullLineComment(stmt)) return null;
  const cleaned = stripComments(stmt).replace(/\s+/g, " ").trim();
  const head = cleaned.match(/^((?:(?:capture|quietly|noisily)\s+)*)(putdocx|p_tdocx)\s+image\s+/i);
  if (!head) return null;
  const pathTok = parsePathToken(cleaned.slice(head[0].length));
  if (!pathTok || pathTok.unsupported) {
    return {
      unsupported: true,
      reason: (pathTok && pathTok.reason) || "missing_document_image_path",
      statement: cleaned.slice(0, 200),
    };
  }
  if (hasUnsafePathForm(pathTok.pathInner) || /["|\r\n]/.test(pathTok.pathInner)) {
    return { unsupported: true, reason: "unsafe_document_image_path", statement: cleaned.slice(0, 200) };
  }
  if (!/\.(png|jpg|jpeg|svg)$/i.test(pathTok.pathInner)) {
    return { unsupported: true, reason: "unsupported_document_image_format", statement: cleaned.slice(0, 200) };
  }
  let options = (pathTok.rest || "").trim();
  if (options.startsWith(",")) options = options.slice(1).trim();
  const widthMatch = options.match(/\bwidth\s*\(\s*([^)]+?)\s*\)/i);
  const heightMatch = options.match(/\bheight\s*\(\s*([^)]+?)\s*\)/i);
  const width = widthMatch ? widthMatch[1].trim() : "";
  const height = heightMatch ? heightMatch[1].trim() : "";
  if (/["|\r\n]/.test(width) || /["|\r\n]/.test(height)) {
    return { unsupported: true, reason: "unsafe_document_image_dimension", statement: cleaned.slice(0, 200) };
  }
  return {
    unsupported: false,
    prefix: head[1] || "",
    command: head[2].toLowerCase(),
    pathInner: pathTok.pathInner,
    pathKind: pathTok.kind,
    width,
    height,
    isSvg: /\.svg$/i.test(pathTok.pathInner),
    statement: cleaned,
  };
}

function matchDocumentSave(stmt) {
  if (isStarFullLineComment(stmt)) return null;
  const cleaned = stripComments(stmt).replace(/\s+/g, " ").trim();
  const head = cleaned.match(/^((?:(?:capture|quietly|noisily)\s+)*)(putdocx|p_tdocx)\s+save\s+/i);
  if (!head) return null;
  const pathTok = parsePathToken(cleaned.slice(head[0].length));
  if (!pathTok || pathTok.unsupported) {
    return {
      unsupported: true,
      reason: (pathTok && pathTok.reason) || "missing_document_save_path",
      statement: cleaned.slice(0, 200),
    };
  }
  if (hasUnsafePathForm(pathTok.pathInner) || /["|\r\n]/.test(pathTok.pathInner)) {
    return { unsupported: true, reason: "unsafe_document_save_path", statement: cleaned.slice(0, 200) };
  }
  return {
    unsupported: false,
    pathInner: pathTok.pathInner,
    pathKind: pathTok.kind,
    quotedPath: pathTok.token,
    statement: cleaned,
  };
}

function buildDocumentImageReplacement(info, helperScript) {
  const markerPathInner = info.isSvg
    ? info.pathInner.replace(/\.svg$/i, ".__docxcompat__.png")
    : info.pathInner;
  const marker =
    `__CODEX_DOCX_IMAGE_V1__|path=${markerPathInner}|width=${info.width}|height=${info.height}` +
    `|__END_CODEX_DOCX_IMAGE_V1__`;
  const lines = [
    `* ${DOCX_COMPAT_MARKER} image marker (temp copy only)`,
  ];
  if (info.isSvg) {
    const qSvg = rewrapPath(info.pathKind, info.pathInner);
    const qPng = rewrapPath(info.pathKind, markerPathInner);
    const qSuccess = rewrapPath(info.pathKind, markerPathInner + ".__pngcompat_ok");
    lines.push(
      `shell /bin/sh ${quoteSh(helperScript)} --svg ${qSvg} --out ${qPng} --format png --width 1200`,
      `capture confirm file ${qPng}`,
      `if _rc {`,
      `    display as error "DOCX_IMAGE_COMPAT_SVG_CONVERT_FAILED"`,
      `    exit 694`,
      `}`,
      `capture confirm file ${qSuccess}`,
      `if _rc {`,
      `    display as error "DOCX_IMAGE_COMPAT_SVG_MARKER_MISSING"`,
      `    exit 694`,
      `}`,
      `capture erase ${qSuccess}`
    );
  }
  lines.push(`${info.prefix}putdocx text ("${marker}")`);
  return lines.join("\n");
}

function buildDocumentSaveReplacement(info, helperScript) {
  const markerPath = rewrapPath(info.pathKind, info.pathInner + ".__docxcompat_ok");
  return [
    `* ${DOCX_COMPAT_MARKER} post-save injection (temp copy only)`,
    info.statement,
    `shell /usr/bin/python3 ${quoteSh(helperScript)} --docx ${info.quotedPath}`,
    `capture confirm file ${markerPath}`,
    `if _rc {`,
    `    display as error "DOCX_IMAGE_COMPAT_FAILED: missing success marker"`,
    `    exit 694`,
    `}`,
    `capture erase ${markerPath}`,
  ].join("\n");
}

/**
 * Build Stata block: SVG export + sh helper + confirm + erase-on-success.
 */
function buildReplacement(info, helperScript) {
  const svgInner = pathInnerToSvg(info.pathInner);
  const qOut = rewrapPath(info.pathKind, info.pathInner);
  const qSvg = rewrapPath(info.pathKind, svgInner);
  const qMarker = rewrapPath(info.pathKind, info.pathInner + ".__pngcompat_ok");
  const fmt = info.asFmt === "jpg" || info.asFmt === "jpeg" ? "jpeg" : "png";
  const width = info.width || 1200;
  const nameOpt = info.name ? ` name(${info.name})` : "";
  // always replace on temp svg; respect original replace on final only via helper overwrite
  const exportLine = `${info.prefix}graph export ${qSvg}, as(svg)${nameOpt} replace`;
  const helper = quoteSh(helperScript);
  // Stata expands macros in shell lines before exec
  const shellLine =
    `shell /bin/sh ${helper} --svg ${qSvg} --out ${qOut} --format ${fmt} --width ${width}`;
  const confSvg = [
    `capture confirm file ${qSvg}`,
    `if _rc {`,
    `    display as error "PNG_COMPAT_SVG_MISSING after graph export"`,
    `    exit 693`,
    `}`,
  ].join("\n");
  const confOut = [
    `capture confirm file ${qOut}`,
    `if _rc {`,
    `    display as error "PNG_COMPAT_CONVERT_FAILED: missing ${info.pathInner.replace(/"/g, "'")}"`,
    `    exit 693`,
    `}`,
    `capture confirm file ${qMarker}`,
    `if _rc {`,
    `    display as error "PNG_COMPAT_CONVERT_FAILED: missing success marker"`,
    `    exit 693`,
    `}`,
  ].join("\n");
  const cleanup = [
    `capture erase ${qSvg}`,
    `capture erase ${qMarker}`,
  ].join("\n");

  return [
    `* PNG_COMPAT_DARWIN raster->svg+sips (temp copy only)`,
    exportLine,
    confSvg,
    shellLine,
    confOut,
    cleanup,
  ].join("\n");
}

function quoteSh(p) {
  return `"${String(p).replace(/"/g, '\\"')}"`;
}

/**
 * Statement-level: looks like a raster graph export that must be rewritten or rejected.
 * Ignores full-line *, // and block comments. Does NOT match shell sips text alone.
 */
function looksLikeRasterGraphExport(stmt) {
  if (isStarFullLineComment(stmt)) return false;
  const cleaned = stripComments(stmt).replace(/\s+/g, " ").trim();
  if (!cleaned) return false;
  if (!/\bgraph\s+export\b/i.test(cleaned)) return false;
  if (/\bas\s*\(\s*(svg|pdf)\s*\)/i.test(cleaned)) return false;
  // path ends with .svg/.pdf and no raster marker → not residual
  if (/\.(svg|pdf)(["']?\s*)(,|$)/i.test(cleaned) && !RASTER_EXT_RE.test(cleaned) && !/\bas\s*\(\s*(png|jpg|jpeg)\s*\)/i.test(cleaned)) {
    return false;
  }
  if (/\bas\s*\(\s*(png|jpg|jpeg)\s*\)/i.test(cleaned)) return true;
  if (RASTER_EXT_RE.test(cleaned)) return true;
  return false;
}

/**
 * Residual raster exports: statements that still look like raster graph export
 * but were not rewritten (parse miss / skip). Used for fail-closed inject.
 */
function findResidualRasterExports(source) {
  const { statements } = logicalStatements(source);
  const residuals = [];
  for (const st of statements) {
    if (!looksLikeRasterGraphExport(st.text)) continue;
    const info = matchGraphExport(st.text);
    if (info && !info.unsupported) {
      // rewriteable — not residual if caller already transformed; still report as residual of original
      residuals.push({
        startLine: st.startLine,
        reason: "rewriteable_raster_present",
        statement: (info.statement || st.text).slice(0, 180),
        pathInner: info.pathInner,
      });
      continue;
    }
    if (info && info.unsupported) {
      residuals.push({
        startLine: st.startLine,
        reason: info.reason || "unsupported",
        statement: (info.statement || st.text).slice(0, 180),
      });
      continue;
    }
    residuals.push({
      startLine: st.startLine,
      reason: "unparsed_raster_graph_export",
      statement: stripComments(st.text).replace(/\s+/g, " ").trim().slice(0, 180),
    });
  }
  return residuals;
}

/**
 * @param {string} source
 * @param {{platform?: string, helperScript?: string, docxHelperScript?: string, convertScript?: string, nodeBin?: string}} options
 */
function transformDoSource(source, options = {}) {
  const platform = options.platform || process.platform;
  if (platform !== "darwin") {
    return {
      ok: true,
      transformed: false,
      platform,
      code: source,
      replacements: [],
      residuals: [],
      note: "non-darwin: no rewrite",
    };
  }

  if (hasDelimitSemicolon(source)) {
    if (findResidualRasterExports(source).length || /\b(?:putdocx|p_tdocx)\s+(?:image|save)\b/i.test(source)) {
      return {
        ok: false,
        error: "PNG_COMPAT_UNSUPPORTED",
        reason: "delimit_semicolon_with_darwin_compat_command",
        code: source,
        replacements: [],
        residuals: findResidualRasterExports(source),
      };
    }
  }

  const helperScript = options.helperScript || defaultHelperScript();
  const docxHelperScript = options.docxHelperScript || defaultDocxHelperScript();
  const { lines, statements } = logicalStatements(source);
  const replacements = [];
  const lineMap = new Map();
  const documentAlreadyTransformed = source.includes(DOCX_COMPAT_MARKER);

  for (const st of statements) {
    const info = matchGraphExport(st.text);
    if (!info) {
      // parse miss but looks like raster → fail-closed (do not leave native PNG)
      if (looksLikeRasterGraphExport(st.text)) {
        return {
          ok: false,
          error: "PNG_COMPAT_UNSUPPORTED",
          reason: "unparsed_raster_graph_export",
          statement: stripComments(st.text).replace(/\s+/g, " ").trim().slice(0, 200),
          code: source,
          replacements,
          residuals: findResidualRasterExports(source),
        };
      }
      continue;
    }
    if (info.unsupported) {
      return {
        ok: false,
        error: "PNG_COMPAT_UNSUPPORTED",
        reason: info.reason,
        statement: info.statement,
        code: source,
        replacements,
        residuals: findResidualRasterExports(source),
      };
    }
    const block = buildReplacement(info, helperScript);
    replacements.push({
      startLine: st.startLine,
      endLine: st.endLine,
      original: info.statement.slice(0, 180),
      pathInner: info.pathInner,
      width: info.width,
      height: info.height,
      format: info.asFmt,
      name: info.name,
    });
    lineMap.set(st.startLine, { endLine: st.endLine, block });
  }

  if (!documentAlreadyTransformed) {
    for (const st of statements) {
      const imageInfo = matchDocumentImage(st.text);
      const saveInfo = matchDocumentSave(st.text);
      const info = imageInfo || saveInfo;
      if (!info) continue;
      if (info.unsupported) {
        return {
          ok: false,
          error: "DOCX_IMAGE_COMPAT_UNSUPPORTED",
          reason: info.reason,
          statement: info.statement,
          code: source,
          replacements,
          residuals: [],
        };
      }
      if (!fs.existsSync(docxHelperScript)) {
        return {
          ok: false,
          error: "DOCX_IMAGE_COMPAT_HELPER_MISSING",
          reason: "docx_image_inject_missing",
          code: source,
          replacements,
          residuals: [],
        };
      }
      const block = imageInfo
        ? buildDocumentImageReplacement(imageInfo, helperScript)
        : buildDocumentSaveReplacement(saveInfo, docxHelperScript);
      replacements.push({
        kind: imageInfo ? "document-image" : "document-save",
        startLine: st.startLine,
        endLine: st.endLine,
        original: info.statement.slice(0, 180),
        pathInner: info.pathInner,
        width: imageInfo ? info.width : null,
        height: imageInfo ? info.height : null,
      });
      lineMap.set(st.startLine, { endLine: st.endLine, block });
    }
  }

  if (!replacements.length) {
    const residuals = findResidualRasterExports(source);
    if (residuals.length) {
      return {
        ok: false,
        error: "PNG_COMPAT_UNSUPPORTED",
        reason: residuals[0].reason || "residual_raster_export",
        residuals,
        code: source,
        replacements: [],
      };
    }
    return {
      ok: true,
      transformed: false,
      platform: "darwin",
      code: source,
      replacements: [],
      residuals: [],
      note: "no raster graph export found",
    };
  }

  const outLines = [];
  let i = 0;
  while (i < lines.length) {
    if (lineMap.has(i)) {
      const { endLine, block } = lineMap.get(i);
      outLines.push(...block.split("\n"));
      i = endLine + 1;
      continue;
    }
    outLines.push(lines[i]);
    i++;
  }

  const code = outLines.join("\n");
  // Post-condition: transformed output must not still contain residual raster exports
  const postResiduals = findResidualRasterExports(code).filter((r) => {
    // rewritten blocks include as(svg) only; residual scanner should not flag them
    return true;
  });
  // Only flag if still looks like native raster export (not our SVG+shell block)
  const truePost = [];
  for (const st of logicalStatements(code).statements) {
    if (!looksLikeRasterGraphExport(st.text)) continue;
    // skip lines inside our generated shell helper invocations
    if (/png_compat_sips\.sh/i.test(st.text)) continue;
    if (/PNG_COMPAT_DARWIN/i.test(st.text)) continue;
    if (/\bas\s*\(\s*svg\s*\)/i.test(st.text)) continue;
    const info = matchGraphExport(st.text);
    if (info && !info.unsupported) {
      truePost.push({
        startLine: st.startLine,
        reason: "post_transform_raster_remaining",
        statement: info.statement.slice(0, 180),
      });
    } else if (looksLikeRasterGraphExport(st.text) && !/\bas\s*\(\s*svg\s*\)/i.test(st.text)) {
      // graph export to .png still present
      if (RASTER_EXT_RE.test(st.text) && /\bgraph\s+export\b/i.test(st.text)) {
        truePost.push({
          startLine: st.startLine,
          reason: "post_transform_raster_remaining",
          statement: stripComments(st.text).replace(/\s+/g, " ").trim().slice(0, 180),
        });
      }
    }
  }
  if (truePost.length) {
    return {
      ok: false,
      error: "PNG_COMPAT_UNSUPPORTED",
      reason: "post_transform_raster_remaining",
      residuals: truePost,
      code: source,
      replacements,
    };
  }

  return {
    ok: true,
    transformed: true,
    platform: "darwin",
    code,
    replacements,
    residuals: [],
    helperScript,
    docxHelperScript,
  };
}

/** Statement-level residual presence (not crude whole-file .png scan). */
function hasRasterGraphExport(source) {
  return findResidualRasterExports(source).length > 0;
}

function validatePngBuffer(buf, expectWidth) {
  if (!buf || buf.length < 24) {
    return { ok: false, error: "PNG_COMPAT_VALIDATE_FAILED", reason: "too_small", bytes: buf ? buf.length : 0 };
  }
  if (!buf.subarray(0, 8).equals(PNG_SIGNATURE)) {
    return { ok: false, error: "PNG_COMPAT_VALIDATE_FAILED", reason: "bad_signature" };
  }
  const width = buf.readUInt32BE(16);
  const height = buf.readUInt32BE(20);
  if (width <= 0 || height <= 0) {
    return { ok: false, error: "PNG_COMPAT_VALIDATE_FAILED", reason: "bad_dims", width, height };
  }
  if (expectWidth) {
    const tol = Math.max(2, Math.round(expectWidth * 0.05));
    if (Math.abs(width - expectWidth) > tol) {
      return {
        ok: false,
        error: "PNG_COMPAT_VALIDATE_FAILED",
        reason: "width_tolerance",
        width,
        expectWidth,
        tol,
      };
    }
  }
  return { ok: true, width, height, bytes: buf.length };
}

/** Node-side convert (tests / fallback). Prefer sh helper in Stata. */
function convertSvgToRaster(svgPath, outPath, format, width, timeoutMs) {
  const helper = defaultHelperScript();
  if (fs.existsSync(helper)) {
    const r = spawnSync(
      "/bin/sh",
      [
        helper,
        "--svg",
        svgPath,
        "--out",
        outPath,
        "--format",
        format === "jpg" || format === "jpeg" ? "jpeg" : "png",
        "--width",
        String(width || 1200),
        "--timeout",
        String(Math.max(5, Math.floor((timeoutMs || 90000) / 1000))),
      ],
      { encoding: "utf8" }
    );
    if (r.status === 0 && fs.existsSync(outPath)) {
      return { ok: true, outPath, bytes: fs.statSync(outPath).size, via: "sh_helper" };
    }
    return {
      ok: false,
      error: "PNG_COMPAT_CONVERT_FAILED",
      reason: "sh_helper_failed",
      status: r.status,
      stderr: (r.stderr || "").slice(0, 400),
    };
  }
  // legacy direct sips
  const fmt = format === "jpg" || format === "jpeg" ? "jpeg" : "png";
  const dir = path.dirname(outPath);
  const stage = path.join(dir, `.pngcompat_stage_${process.pid}_${Date.now()}.${fmt === "jpeg" ? "jpg" : "png"}`);
  try {
    if (fs.existsSync(stage)) fs.unlinkSync(stage);
  } catch {}
  const r = spawnSync(
    "/usr/bin/sips",
    ["-s", "format", fmt, "--resampleWidth", String(width || 1200), svgPath, "--out", stage],
    { encoding: "utf8", timeout: timeoutMs || 90000 }
  );
  if (r.status !== 0) {
    try {
      if (fs.existsSync(stage)) fs.unlinkSync(stage);
    } catch {}
    return {
      ok: false,
      error: "PNG_COMPAT_CONVERT_FAILED",
      reason: "sips_failed",
      stderr: (r.stderr || "").slice(0, 400),
      status: r.status,
    };
  }
  if (!fs.existsSync(stage)) {
    return { ok: false, error: "PNG_COMPAT_CONVERT_FAILED", reason: "stage_missing" };
  }
  const buf = fs.readFileSync(stage);
  if (fmt === "png") {
    const v = validatePngBuffer(buf, width || 1200);
    if (!v.ok) {
      try {
        fs.unlinkSync(stage);
      } catch {}
      return v;
    }
  } else if (buf.length < 32) {
    try {
      fs.unlinkSync(stage);
    } catch {}
    return { ok: false, error: "PNG_COMPAT_VALIDATE_FAILED", reason: "jpeg_too_small" };
  }
  fs.renameSync(stage, outPath);
  return { ok: true, outPath, bytes: buf.length, via: "direct_sips" };
}

module.exports = {
  transformDoSource,
  validatePngBuffer,
  convertSvgToRaster,
  matchGraphExport,
  hasRasterGraphExport,
  findResidualRasterExports,
  looksLikeRasterGraphExport,
  stripComments,
  PNG_SIGNATURE,
  defaultHelperScript,
  defaultDocxHelperScript,
  matchDocumentImage,
  matchDocumentSave,
  buildDocumentImageReplacement,
  buildDocumentSaveReplacement,
};

function main(argv) {
  if (argv.includes("--svg") && argv.includes("--out")) {
    const get = (flag) => {
      const i = argv.indexOf(flag);
      return i >= 0 ? argv[i + 1] : null;
    };
    const svg = get("--svg");
    const out = get("--out");
    const format = get("--format") || "png";
    const width = parseInt(get("--width") || "1200", 10);
    const r = convertSvgToRaster(svg, out, format, width);
    process.stdout.write(JSON.stringify(r) + "\n");
    process.exit(r.ok ? 0 : 1);
  }

  const file = argv[2];
  if (!file || file.startsWith("-")) {
    process.stderr.write(
      "Usage:\n  node png_compat_transform.js <file.do>\n  node png_compat_transform.js --svg in.svg --out out.png --format png --width 1200\n"
    );
    process.exit(2);
  }
  const src = fs.readFileSync(file, "utf8");
  const r = transformDoSource(src, { platform: process.platform });
  process.stdout.write(JSON.stringify(r, null, 2) + "\n");
  process.exit(r.ok ? 0 : 1);
}

if (require.main === module) {
  main(process.argv);
}
