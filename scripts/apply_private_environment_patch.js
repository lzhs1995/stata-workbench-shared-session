"use strict";

// Final maintained layer. Do not change the pinned upstream reference or any
// installed extension. The patch/revert API operates on text supplied by root.
const fingerprint = require("./finalize_bundle_identity");
const MARKER = "/* Workbench: private runtime and debug environments */";
const PAIRS = [
  ['MO=process.env,GO=', 'MO={...process.env},GO='],
  ['nag=g=>{MO=g||process.env}', 'nag=g=>{MO=g&&g!==process.env?g:{...process.env}}'],
  ['wag=()=>Ta.getStore()?.env||MO||process.env', 'wag=()=>Ta.getStore()?.env||MO'],
  // Keep caller-owned request objects usable, but never alias the host env.
  ['env:g?.env??MO,fs:g?.fs??GO', 'env:(__env=>__env===process.env?{...process.env}:__env??MO)(g?.env),fs:g?.fs??GO'],
  [
    'function jKA(g){g?process.env.DEBUG=g:delete process.env.DEBUG}function ZKA(){return process.env.DEBUG}',
    'var __codexPrivateDebugValue=process.env.DEBUG;function jKA(g){__codexPrivateDebugValue=g?`${g}`:void 0}function ZKA(){return __codexPrivateDebugValue}',
  ],
];

function once(source, needle, replacement) {
  if (source.split(needle).length !== 2)
    throw new Error("missing or ambiguous private-environment anchor: " + needle.slice(0, 100));
  return source.replace(needle, () => replacement);
}

function verifyPatched(source) {
  if (source.split(MARKER).length !== 2) throw new Error("missing or ambiguous private-environment marker");
  for (const [before, after] of PAIRS) {
    if (source.split(after).length !== 2 || source.includes(before))
      throw new Error("partial or ambiguous private-environment patch: " + after.slice(0, 100));
  }
}

function patchBundle(source, options = {}) {
  if (source.includes(MARKER)) verifyPatched(source);
  else {
    for (const [before, after] of PAIRS) source = once(source, before, after);
    source += "\n" + MARKER + "\n";
    verifyPatched(source);
  }
  return options.finalize === false ? source : fingerprint.finalize(source).text;
}

function revertBundle(source, options = {}) {
  verifyPatched(source);
  source = once(source, "\n" + MARKER + "\n", "");
  for (const [before, after] of [...PAIRS].reverse()) source = once(source, after, before);
  return options.finalize === false ? source : fingerprint.finalize(source).text;
}

module.exports = { patchBundle, revertBundle, MARKER, PAIRS };
