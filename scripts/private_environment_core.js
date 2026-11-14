"use strict";

const { isMainThread } = require("node:worker_threads");

// Copy values once; no trap retains or writes the host environment. Windows
// workers have a case-sensitive env, unlike the Windows main thread.
function snapshotEnvironment(source = process.env, options = {}) {
  const insensitive = (options.platform ?? process.platform) === "win32" &&
    (options.isMainThread ?? isMainThread);
  const values = {}, names = new Map();
  const folded = key => insensitive ? key.toUpperCase() : key;
  const actual = key => typeof key === "string" ? names.get(folded(key)) : key;
  function put(key, value) {
    // Template coercion follows ToString (including a thrown Symbol value).
    const text = typeof key === "string" ? `${value}` : value;
    const name = actual(key) ?? key;
    Object.defineProperty(values, name, { value: text, configurable: true, enumerable: true, writable: true });
    if (typeof key === "string") names.set(folded(key), name);
    return true;
  }
  for (const key of Reflect.ownKeys(source)) {
    if (Object.getOwnPropertyDescriptor(source, key)?.enumerable) put(key, source[key]);
  }
  return new Proxy(values, {
    get(target, key, receiver) { return Reflect.get(target, actual(key) ?? key, receiver); },
    set(_target, key, value) { return put(key, value); },
    has(target, key) { return Reflect.has(target, actual(key) ?? key); },
    deleteProperty(target, key) {
      const name = actual(key) ?? key;
      const removed = Reflect.deleteProperty(target, name);
      if (removed && typeof key === "string") names.delete(folded(key));
      return removed;
    },
    getOwnPropertyDescriptor(target, key) {
      return Reflect.getOwnPropertyDescriptor(target, actual(key) ?? key);
    },
    ownKeys(target) { return Reflect.ownKeys(target); },
    defineProperty(_target, key, descriptor) {
      if (typeof key === "symbol") return Reflect.defineProperty(values, key, descriptor);
      if (!("value" in descriptor) || "get" in descriptor || "set" in descriptor ||
          descriptor.configurable !== true || descriptor.enumerable !== true || descriptor.writable !== true) {
        const error = new TypeError("environment only accepts a configurable, writable, enumerable data descriptor");
        error.code = "ERR_INVALID_OBJECT_DEFINE_PROPERTY";
        throw error;
      }
      return put(key, descriptor.value);
    },
    // Prevent non-extensible targets from violating case-alias descriptor
    // invariants, matching the non-freezable host environment boundary.
    preventExtensions() { return false; },
  });
}

module.exports = { snapshotEnvironment };
