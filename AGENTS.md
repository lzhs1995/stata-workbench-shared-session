# AGENTS.md

Entry point for AI agents and for the people who set them up. Instructions are
plain Markdown and do not depend on one vendor's agent.

## Pick your task

| You want to | Read |
| --- | --- |
| Run Stata code in a person's existing session, so you and the person share one visible Stata | The operating skill (below). It is the authority for this route |
| Change this repository (extension runtime, tools, docs) | [Changing this repository](#changing-this-repository) and [CONTRIBUTING.md](CONTRIBUTING.md) |
| Install the extension for a person | [README.md](README.md#install) ([简体中文](README.zh-CN.md#安装), [繁體中文](README.zh-TW.md#安裝)) |

## Running Stata in a person's session

Read the operating skill first:
[stata-workbench-shared-session-skill](https://github.com/lzhs1995/stata-workbench-shared-session-skill),
file `skills/stata-workbench-shared-session/SKILL.md`. It matches runtime
`v0.1.3-rc.7.45`; the pins are in that repository's `runtime-compatibility.json`.
Its `scripts/install.py` (dry run by default) can link the skill into
`.claude/skills`, `.codex/skills` and `.agents/skills`. Any other agent can read
SKILL.md directly.

The rules that matter most, in short. SKILL.md has the full text:

- Use the person's existing session. The tools in `tools/` come from a clone of
  this repository checked out at the tag of the installed VSIX.
- Set `STATA_WORKBENCH_PROFILE` and `STATA_WORKBENCH_PORT` to the person's real
  profile and port. The README values are only defaults.
- Check first: `python3 -B tools/verified_workbench.py --status`. Then run with
  `python3 -B tools/shared_stata.py --file <saved .do> --cwd <dir>`
  (Windows: `python`). One POST per call; the client never retries.
- Exit 0 means verdict `PASS_VISIBLE_SHARED_RUN`. `EXECUTION_UNCONFIRMED_NO_RETRY`
  does not mean "did not run": read the receipt before doing anything else and
  never resend that call.
- Never start a second Stata, backend or VS Code profile to get around a busy,
  STALE or missing session. Never kill Stata. Call `/force-reset` or
  `/panic-kill` only when the person asks for it.
- Do not save or discard the person's unsaved edits. Do not commit
  `.stata-receipts/`, research data, logs or credentials.

## Changing this repository

Offline checks (no Stata, GUI or credentials needed):

```sh
npm ci --ignore-scripts
npm run check
python3 -B -m unittest discover -s tools -p 'test_*.py'
python3 -B tools/verify_release.py
```

- `npm run check` is read-only. `check:legacy` rewrites files; never run it on a
  sealed release candidate.
- `dist/extension.js`, `scripts/` and `tools/` files listed in
  `release/runtime-manifest.json` are the runtime identity. Changing them needs a
  new version and new licensed acceptance on macOS and Windows; see
  [docs/RELEASE.md](docs/RELEASE.md).
- Keep upstream attribution ([NOTICE](NOTICE)). Use synthetic data in tests and
  examples; never add personal paths, research files or receipts.

## What has been checked with agents

- Reading: with no prior context, a Claude Code subagent and a Codex session each
  read only SKILL.md and answered a 10-question operating test (19/20 and 17/20;
  pass line 16, no zero on the safety questions), 2026-10-31 and 2026-11-01.
- Running: the agent client `tools/shared_stata.py` was exercised on rc.7.45 on
  macOS and Windows; see [README.md](README.md#platform-status).
- Not checked: live runs started by each named agent product through an
  installed skill route, and agents other than Claude Code and Codex.
