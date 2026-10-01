# Disk planning, verified backup and SMCL receipts

These lessons concern long historical Stata pipelines in an existing shared
Workbench. They supplement [execution policy and concurrency](shared-execution-and-concurrency.md).
They do not change the runtime, create a cloud connector or certify concurrent
Stata instances.

## Budget each unsubmitted stage

Measure free space before dispatch. Estimate the largest simultaneous DTA, CSV,
temporary and verification files, plus a reserve for the shared machine. A small
input can expand sharply after reshape or join; compressed backup size is not
the space needed to execute or restore it. Stage large exports one branch at a
time. Preserve any disk-full error and partial outputs before versioning a repair.

When space is insufficient, defer that write-heavy stage and continue independent
source review, receipt reconciliation, documentation and backup preparation.
Do not lower the budget merely to pass a check, restart the backend or submit a
completed stage again. A user-permitted covered window is a separate condition
and does not prevent these activities.

## Back up before reclaiming local storage

1. Select owned, completed, stable outputs. Keep raw inputs, failed attempts and
   active work outside the reclamation set. Record paths, bytes, SHA-256, file
   identity and terminal receipts in a manifest.
2. Build bounded packages and stream-check the complete member set and every
   member's bytes against the manifest. Recheck source stability. A local archive
   is prepared evidence, not a remote backup.
3. Use the authorized destination and existing client/account binding. Coordinate
   its transfer consumer through the existing owner and queue. Desktop focus is
   a separate short lease; network waits need not hold focus. Do not change account
   settings, operate another owner's transfer or create a competing queue.
4. Record upload intent once, then inspect that task to settlement. Remote listing,
   size or an upload success code alone is insufficient. Download through the
   normal client into a new private location and verify the entire SHA-256.
   Keep the manifest recoverable with the package. An unknown transfer is never
   an instruction to upload or download it again.
5. Reconcile controller/child terminal receipts and consumer release. Only then
   consider explicitly authorized local reclamation. Record the exact files and
   the measured allocation change; do not infer free space from logical bytes.

On macOS, transparent filesystem compression can preserve ordinary file bytes
and paths. Before replacing a generated file, verify ownership, terminal status,
absence of open handles, no symlink/hard-link ambiguity and sufficient temporary
space. Verify the compressed copy's complete ordinary SHA, size, mode and mtime,
recheck the source identity, then replace and verify again. Record both inodes
and allocated blocks. Never rewrite old manifests to conceal the inode change;
publish a storage-maintenance receipt. This is not a change to Stata data values.

Project evidence recorded four complete cloud round trips and twenty generated
DTA files transparently compressed with ordinary bytes preserved. Later batches
must earn their own receipts. This is experience with a task-specific adapter,
not a universal Baidu API or product support guarantee.

## Read SMCL markers without mistaking echoed code for output

A successful native Stata log may prefix a printed marker with `{res}`, `{txt}`
or `{err}`. A plain line-start regex can reject that output even when the actual
request succeeded. Preserve the raw log and repair only the reader in a new
version; do not rerun the successful producer to fix a verifier.

For a marker contract tested with these prefixes, remove only consecutive known
prefix tokens at the start of each line, then require an exact complete marker
line with the expected stage identity and return code. Do not strip all braces,
search for an arbitrary substring or interpret the color token as the return
status. For example:

```text
{res}{txt}TASK_RETURN_example=0       accepted by the prefix reader
. display "TASK_RETURN_example=0"    rejected: echoed command
TASK_RETURN_example=602              rejected when the contract requires 0
TASK_RETURN_example=0junk            rejected: trailing text
{foo}TASK_RETURN_example=0            rejected: unknown prefix
```

The example's explanations are not part of a marker. Reader acceptance is only
one check: still bind the raw log, program SHA, request/run/backend identity,
terminal status and actual outputs. A missing or uncertain execution outcome
stays unresolved. Preserve the old failed verification, add the supplemental
result and resume only the unsubmitted suffix after all dependencies pass.

The local repair passed nine positive/negative fixtures, accepted the original
native marker and preserved four producer/verifier predecessor versions. It did
not change the raw logs, fit models or establish scientific validity.
