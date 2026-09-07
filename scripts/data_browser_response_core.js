"use strict";

function getVariablesFromResponse(response) {
  if (!response || typeof response !== "object") return [];
  if (Array.isArray(response.variables)) return response.variables;
  if (Array.isArray(response.vars)) return response.vars;
  return [];
}

module.exports = { getVariablesFromResponse };
