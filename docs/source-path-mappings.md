# Explicit source-path mappings

Workbench no longer redirects a particular Windows account's Desktop or guesses
a research folder from the workspace. The default `stataMcp.sourcePathMappings`
is an empty array. With that default, Windows path roots remain the same on Mac;
normal Mac separator, transport-log, pagination and graph compatibility still
apply. An unavailable path produces an ordinary preparation/Stata error rather
than silently selecting a different person's directory.

To migrate an existing script, review the literal source root and its intended
local destination, then explicitly add a mapping to VS Code user or workspace
settings. Workbench never writes this setting or rewrites the original source.
The following is a synthetic example; replace both paths deliberately:

```json
{
  "stataMcp.sourcePathMappings": [
    {
      "from": "C:/Users/Example Analyst/Desktop/Study Project/data",
      "to": "/Users/fixture/datasets/研究 資料"
    },
    {
      "from": "C:/Users/Example Analyst/Desktop/Study Project",
      "to": "/Users/fixture/projects/Study Project"
    }
  ]
}
```

Mappings apply to literal absolute path tokens in submitted code and temporary
copies of statically referenced `.do` files. The longest matching source prefix
wins, regardless of array order. Matching requires either the complete root or
a following directory separator: `Study Project` does not match
`Study Project-archive`. The replacement is performed once per token; replacement
text is not fed back into the mapping list. Quoted spaces and Unicode are kept.
Backslashes and forward slashes are interchangeable when matching. Windows drive
and UNC source prefixes are case insensitive; POSIX prefixes are case sensitive.
Destination paths use forward slashes, which Stata accepts on both platforms.
An unquoted token whose destination needs quotes is quoted automatically.

Both `from` and `to` must be literal absolute directory roots. Relative roots,
dot segments, control characters, double quotes, Stata macros and duplicate
source prefixes are refused. `~`, environment-variable expansion and inferred
home directories are not supported. Windows UNC paths must include a server and
share. On Windows, explicit mappings can target another Windows drive or share;
with no mappings, native source paths retain the existing behavior.

Run File and Run Selection read settings for the source document's resource in
the receiving VS Code window. The agent workflow passes its selected source
path to the same adapter, so folder-specific configuration uses that source
resource even when execution runs an immutable receipt copy. Terminal input and
legacy agent requests without a source path use the receiving window's default
configuration. Changes take effect on the next preparation; already prepared
executions are not rewritten.

The finalizer still owns the original execution scope, return code and completion
marker. Its generated body is traversed by the shared adapter, which creates a
mapped execution copy and leaves the original file and verified body unchanged.
Mac PNG/DOCX conversion and transport-log protection remain active. Diagnostics
report `configuredPathMappings`, `rootRewrites`, and referenced-copy SHA evidence.
An embedded path inside explanatory prose is left alone; for example, a generated
error message may still quote the original source path while its actual file
operands use the mapped destination.

This is literal path substitution, not a Stata interpreter. It does not expand
runtime macros or infer the working directory after dynamic code. Existing
static-reference limits (depth, count, byte budget, and uncertain relative paths)
remain in force; explicit mappings also propagate recursively on Windows.
Unsupported dynamic references remain reported as partial coverage. Invalid
mapping configuration fails preparation; it does not fall back to executing
the unmodified request.

Release integration must register the setting as an array of `{from,to}` objects
with default `[]` and resource scope, include the source compatibility modules,
and replay `scripts/apply_stata_source_path_mappings_patch.js` **after** the
existing shared compatibility/finalizer and later bundle patches (including
daily window/lifecycle patches), before final bundle fingerprinting. The new
layer is reversible and idempotent. Root owns the schema, replay-list integration
and regenerated package; the implementation does not edit user settings.
