# Native export failures and usable research delivery

## Establish native termination before continuing

A cancelled HTTP request, a settled transport promise and an exited controller
do not establish that embedded Stata has stopped. Record these separately from
the native worker's state. Inspect the original worker identity, open output
files, log progress and a bounded native stack sample where available. Never
clear readiness flags, launch a replacement backend or replay a request simply
because its transport returned a terminal result.

In one macOS shared-session incident, the first PNG export left a zero-byte
file open. A native sample showed the Stata bitmap conversion path waiting in
Java/AWT AppKit initialization while the Python main thread remained in its
event loop. This supports a native wait in that observed process; it does not
prove the root cause of every graph timeout, a general macOS defect or a remedy.
An earlier Windows graphics incident is not evidence for the same cause.

A bridge cleanup patch can repair its own request bookkeeping without releasing
that native wait. Keep its offline tests, installation, loaded code and actual
session recovery as separate statuses. Use only supported recovery on the bound
session, and preserve failed receipts. Do not repeatedly send breaks or escalate
to resetting shared state without the necessary recovery authority.

## Follow the actual wire through nested DO files

The incident also exposed a plugin coverage gap. The installed adapter prepared
one referenced DO, but did not inspect a second DO called by that wrapper. The
recorded request reported zero Darwin conversions and no compatibility copies;
an offline replay of that exact wire reproduced those diagnostics. Recursive
preparation reached the 24 raster exports in the inner export file. This ties
the compatibility gap to the failed request without claiming that VS Code as
a whole stopped responding or that the underlying Java/AWT defect is fixed.

The adapter now prepares literal, double-quoted `.do` references recursively on
macOS, writing temporary execution copies from child to parent. It preserves
the author's source bytes and path-token surrounding text. Commented and quoted
examples, including multiline compound strings, are not DO commands. Retain
`sourceCompatibility` and `darwinCompatibility` from the same request as its
wire, cwd, source hashes, and prepared copy hashes.

This is a bounded static scanner, not a Stata interpreter:

- Only line-start `do` with optional capture/quietly/noisily prefixes is followed.
  Macro paths, `run`, `include`, and semicolon-delimited references are reported
  as `partial-static` and retained; other dynamic command forms are not certified.
- A changed or uncertain working directory prevents guessing relative DO paths.
  Use explicit absolute paths in an isolated execution wrapper when needed.
- Missing literal files, cycles, more than 16 nested files, 256 reference visits,
  or 16 MiB cumulative source reads fail preparation. A literal file generated
  later at run time must be split into a separately prepared stage after it exists.
- A descendant conversion failure rejects the complete prepared submission;
  `capture do` cannot hide that failure and continue the rest of the wrapper.
- Unsupported dynamic references are not a complete graph safety guarantee.
  Inspect/materialize the actual export DO before using that route for raster
  export. Do not send native PNG probes into an occupied research session.

SVG plus the macOS converter avoids this observed native raster path, but is
not a claim of pixel identity with Stata's native PNG rendering. Source tests,
package dependency tests, installed code, loaded code, and real graph output
must each be evidenced separately. Offline conversion of a DO is not a graph.

A bounded recovery on the existing Workbench successfully reloaded a saved GPH
and exported it through a frozen, preconverted SVG/converter DO: Stata returned
0 and produced a decoded, nonblank 1200 × 800 RGB PNG (93,621 bytes). No data or
model was recalculated. The earlier recovery attempt used `graph use ..., nodraw`
and failed at SVG export with `could not find Graph window`, r(693), before the
converter ran. Removing `nodraw` in a new isolated recovery copy resolved that
specific failure. Retain both attempts; r(693) alone is not a disk-full diagnosis.

The successful recovery used the candidate's prepared files through the existing
extension; the candidate extension itself was not installed or hot-loaded. This
validates one saved-graph recovery, not every graph or the full nested research
chain. Loading/drawing a private graph inside Stata does not require stealing OS
focus when the user has authorized covered or hidden Workbench execution.

The shared Python client preserves a failed `_httperror` response verbatim and
extracts its run/request identity and return code into a separate diagnostic
file. Conflicting envelope fields are not combined. HTTP errors remain failed
even if nested or top-level fields look successful, and a missing ID never
authorizes a retry. Record HTTP settlement and native termination separately.

## Export data before independent graph stages

Save data checkpoints before graph conversion. Put precision CSV exports in a
separate saved DO file with its own receipt, output directory and completion
markers. Graph export failures must not prevent delivery of an already-saved
dataset. For an existing failed run, bind audited DTA inputs by hash and export
them to a new directory after the native session is genuinely available; do not
recompute a successful data block merely to recover its missing CSV files.

Preserve variable order, literal string identifiers, Stata missing-value codes
and the author's naming. Record formatting changes such as `%24.17g` separately
from transformations of stored values. Compare exported strings and numeric
values against the saved DTA, including missing values and column membership;
CSV has no substitute for the DTA's labels, types and metadata. Keep the
author's rounded export as a separate historical artifact.

Use short, readable Stata commands and comments explaining each narrow change.
Shared-session protection belongs in a clearly identified wrapper. Do not bury
the author's transformation logic in an unrelated framework. A prepared DO is
not an executed DO, a source span is not dynamic branch coverage, and completed
stage counts are not counts of fully reproduced source files.

## Deliver files a researcher can open

Organize actual DTA, CSV and executable/commented DO files under chapter folders,
with upstream inputs and historical comparisons. If chapter attribution is
unresolved, use an explicitly named cross-chapter folder and explain the gap.
The chapter README should link the real files, state their execution order,
distinguish runnable and review-only code, and list concrete unresolved issues.
JSON manifests and hashes support this delivery; they do not replace the files.

For large remote files, provide a verified retrieval location and instructions
only after upload and ordinary roundtrip content verification. A requested path
or local archive is not a cloud download link. Distinguish full-file equality,
common-column value equality, metadata differences and unverified historical R
adoption. Do not infer downstream adoption or alter manuscripts from equal N.

Backup budgets include the user's reserve plus peak upload/download/extraction
writes. Process bounded packages and recheck actual free space. Files still open
by a failed worker can be retained as clearly labelled failure snapshots; they
are not terminal outputs and must not be cleaned up as completed work. See
[storage and recovery](storage-and-log-recovery.md).

This is operational guidance from a bounded incident and delivery audit. It
does not install a runtime fix, certify native recovery, establish scientific
validity or certify simultaneous execution in multiple Stata instances.
