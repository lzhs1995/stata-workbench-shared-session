#!/usr/bin/env node
"use strict";

const assert = require("assert");
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const yauzl = require("yauzl");

const root = path.join(__dirname, "..");
const requiredFiles = [
  "autocomplete.js",
  "data-browser.css",
  "data-browser.js",
  "design.css",
  "highlight.css",
  "highlight.min.js",
  "main.js",
  "mark.min.js",
];
const passthroughFiles = requiredFiles.filter((name) => name !== "data-browser.js");

function sha256(buffer) {
  return crypto.createHash("sha256").update(buffer).digest("hex");
}

function assertSemanticContent(files, prefix) {
  const main = files.get(`${prefix}/main.js`).toString("utf8");
  const design = files.get(`${prefix}/design.css`).toString("utf8");
  for (const marker of ["smclToHtml: function", "parseSMCL: function", "processSyntaxHighlighting: function"]) {
    assert.ok(main.includes(marker), `${prefix}/main.js missing ${marker}`);
  }
  for (const marker of ["--bg-app: #09090b;", ".input-area", ".output-content"]) {
    assert.ok(design.includes(marker), `${prefix}/design.css missing ${marker}`);
  }
}

function readRepoFiles(prefix) {
  const files = new Map();
  for (const name of requiredFiles) {
    const file = path.join(root, prefix, name);
    assert.ok(fs.existsSync(file), `missing ${prefix}/${name}`);
    const buffer = fs.readFileSync(file);
    assert.ok(buffer.length > 0, `empty ${prefix}/${name}`);
    files.set(`${prefix}/${name}`, buffer);
  }
  return files;
}

function validatePairs(files, sourcePrefix, distPrefix) {
  for (const name of passthroughFiles) {
    assert.strictEqual(
      sha256(files.get(`${sourcePrefix}/${name}`)),
      sha256(files.get(`${distPrefix}/${name}`)),
      `${name} must be byte-identical in source and dist`,
    );
  }
  const sourceDataBrowser = files.get(`${sourcePrefix}/data-browser.js`);
  const distDataBrowser = files.get(`${distPrefix}/data-browser.js`);
  assert.ok(distDataBrowser.length > sourceDataBrowser.length, "dist data-browser.js must be the bundled browser artifact");
  assert.notStrictEqual(sha256(sourceDataBrowser), sha256(distDataBrowser));
  assert.ok(!/^\s*(?:import|export)\s/m.test(distDataBrowser.toString("utf8")), "bundled data-browser.js must not expose module imports");
}

function validateRepo() {
  const files = new Map([
    ...readRepoFiles(path.join("src", "ui-shared")),
    ...readRepoFiles(path.join("dist", "ui-shared")),
  ]);
  assertSemanticContent(files, path.join("src", "ui-shared"));
  assertSemanticContent(files, path.join("dist", "ui-shared"));
  validatePairs(files, path.join("src", "ui-shared"), path.join("dist", "ui-shared"));
  console.log(`UI_SHARED_REPO_INTEGRITY_PASS ${requiredFiles.length * 2}/16`);
}

function readVsix(vsixPath) {
  return new Promise((resolve, reject) => {
    yauzl.open(vsixPath, { lazyEntries: true }, (openError, zipfile) => {
      if (openError) return reject(openError);
      const wanted = new Set();
      for (const prefix of ["extension/src/ui-shared", "extension/dist/ui-shared"]) {
        for (const name of requiredFiles) wanted.add(`${prefix}/${name}`);
      }
      const files = new Map();
      zipfile.on("error", reject);
      zipfile.on("entry", (entry) => {
        if (!wanted.has(entry.fileName)) {
          zipfile.readEntry();
          return;
        }
        assert.ok(entry.uncompressedSize > 0, `empty VSIX entry ${entry.fileName}`);
        zipfile.openReadStream(entry, (streamError, stream) => {
          if (streamError) return reject(streamError);
          const chunks = [];
          stream.on("data", (chunk) => chunks.push(chunk));
          stream.on("error", reject);
          stream.on("end", () => {
            files.set(entry.fileName, Buffer.concat(chunks));
            zipfile.readEntry();
          });
        });
      });
      zipfile.on("end", () => {
        try {
          for (const name of wanted) assert.ok(files.has(name), `VSIX missing ${name}`);
          resolve(files);
        } catch (error) {
          reject(error);
        }
      });
      zipfile.readEntry();
    });
  });
}

async function validateVsix(explicitPath) {
  const packageJson = JSON.parse(fs.readFileSync(path.join(root, "package.json"), "utf8"));
  const vsixPath = explicitPath || path.join(root, `${packageJson.name}-${packageJson.version}.vsix`);
  assert.ok(fs.existsSync(vsixPath), `VSIX not found: ${vsixPath}`);
  const archive = await readVsix(vsixPath);
  const files = new Map();
  for (const [name, buffer] of archive) files.set(name.replace(/^extension\//, ""), buffer);
  assertSemanticContent(files, "src/ui-shared");
  assertSemanticContent(files, "dist/ui-shared");
  validatePairs(files, "src/ui-shared", "dist/ui-shared");
  console.log(`UI_SHARED_VSIX_INTEGRITY_PASS ${requiredFiles.length * 2}/16 ${vsixPath}`);
}

if (process.argv.includes("--vsix")) {
  const index = process.argv.indexOf("--vsix");
  const explicitPath = process.argv[index + 1] && !process.argv[index + 1].startsWith("--")
    ? path.resolve(process.argv[index + 1])
    : null;
  validateVsix(explicitPath).catch((error) => {
    console.error(error.stack || error.message || error);
    process.exit(1);
  });
} else {
  validateRepo();
}
