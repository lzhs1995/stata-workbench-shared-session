"use strict";

// Offline stand-in for the runtime metadata probe. It reports the facts a
// verified virtual environment would print; nothing is executed.
const path = require("node:path");

function venvFacts(python, platform, overrides = {}) {
  // Joined with the target separator: offline tests may simulate the other platform.
  const root = path.dirname(path.dirname(python)), separator = platform === "win32" ? "\\" : "/";
  const site = root + separator + (platform === "win32" ? "Lib\\site-packages" : "lib/python3.11/site-packages");
  return { prefix: root, basePrefix: root + separator + "base-python", version: [3, 11, 15],
    packages: { "mcp-stata": { version: "1.26.1", location: site }, mcp: { version: "1.28.1", location: site } },
    ...overrides };
}

function venvProbe(platform, overrides, calls) {
  return async (python, args, options) => {
    if (calls) calls.push({ python, args, options });
    const facts = typeof overrides === "function" ? overrides(venvFacts(python, platform)) : venvFacts(python, platform, overrides);
    return { stdout: JSON.stringify(facts) + "\n", stderr: "" };
  };
}

module.exports = { venvFacts, venvProbe };
