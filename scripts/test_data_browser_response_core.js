#!/usr/bin/env node
"use strict";

const assert = require("assert");
const { getVariablesFromResponse } = require("./data_browser_response_core");

const current = [{ name: "make" }, { name: "price" }];
const legacy = [{ name: "mpg" }];

assert.deepStrictEqual(getVariablesFromResponse({ variables: current }), current);
assert.deepStrictEqual(getVariablesFromResponse({ vars: legacy }), legacy);
assert.deepStrictEqual(getVariablesFromResponse({ variables: [], vars: legacy }), []);
assert.deepStrictEqual(getVariablesFromResponse({}), []);
assert.deepStrictEqual(getVariablesFromResponse(null), []);

console.log("DATA_BROWSER_RESPONSE_CORE_PASS");
