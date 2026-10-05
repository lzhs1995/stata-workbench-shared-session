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
