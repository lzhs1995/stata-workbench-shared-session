# Acceptance Scope

`release/acceptance-summary.json` is a sanitized projection of retained local
evidence, with the original record SHA256. It is not a public replay dataset.
Private research paths and logs are omitted. Readers can verify package/runtime
hashes and run offline tests, but cannot replay private logs from a summary alone.

- Runtime 0.1.3-rc.7.39 on one licensed local Mac environment.
- FULL45 45/45 scenarios, 632/632 steps: 575 assertions and 57 observations.
- One full invocation, zero automatic full-run retries. 110 lease-creating steps
  produced 111 receipts because S29 step21 had one bounded zero-ACK product retry.
- Six native runs retained evidence; S41 closed its own log, so retained source
  and completion proof are not a full transcript.
- Original replay failed; separate replay-contract correction passed 795 manifest
  members and 44 negative controls. Failed evidence was preserved.
- Human Run File handler -> AI client -> Human Run File handler used the same
  backend. Automated handler invocation is not a claim of human keypresses.
- Final isolation 17/17, zero leases, eight protected originals unchanged.

## Public Packaging

The private accepted VSIX contained a local maintenance token in a helper and
document; it is not uploaded. The public VSIX removes the token and updates docs
and tools. Executable extension runtime/JS helpers/UI are checked against the
accepted package. New portable tools have separate tests, not inherited FULL45.

The extension version remains 0.1.3-rc.7.39 because its runtime is unchanged;
the immutable GitHub tag adds `-public.1` to distinguish packaging. Future runtime
changes must increment the extension version. Never replace a published asset.
This is not Windows/Linux or universal Stata/editor certification.
