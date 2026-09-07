"use strict";

const LONG_RUNNING_COMMAND = /\b(?:use|merge|append|joinby|collapse|reshape|tab1|regress|logit|probit|poisson|mixed|melogit|sem|gsem|coefplot)\b/i;
const MI_COMMAND = /\bmi\s+(?:impute|estimate|xeq|convert|set|register|passive)\b/i;

function isLongManualSelection(code) {
  const text = String(code == null ? "" : code);
  const lineCount = text ? text.split(/\r?\n/).length : 0;

  return MI_COMMAND.test(text)
    || text.length >= 8000
    || lineCount >= 120
    || (lineCount >= 40 && LONG_RUNNING_COMMAND.test(text));
}

module.exports = {
  isLongManualSelection,
};
