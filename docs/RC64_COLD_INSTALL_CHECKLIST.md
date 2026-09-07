> Historical document: current public release instructions and scope are in [QUICKSTART](QUICKSTART.md), [ACCEPTANCE](ACCEPTANCE.md) and [RELEASE](RELEASE.md). Older platform/version claims below do not certify the current version.

# 0.1.3-rc.6.4.4 Cold-Install and Cold-Upgrade Checklist

This checklist validates the candidate without touching the existing 17485 or 17495 profiles. It does not certify Windows.

## Identity Gate

Use a new profile and port `17515`; do not reuse the accepted rc.6.4.3 profile on `17505`:

```bash
export RC64_ROOT="<local-home>/Documents/cnm/tasks/07_Stata-workbench/stata-workbench-shared-session"
export RC64_VSIX="$RC64_ROOT/stata-workbench-shared-session-0.1.3-rc.6.4.4.vsix"
export RC64_HOME="$HOME/.stata-workbench-rc644-profile"
export RC64_PORT=17515

mkdir -p "$RC64_HOME/user-data/User" "$RC64_HOME/extensions"
code --user-data-dir "$RC64_HOME/user-data" --extensions-dir "$RC64_HOME/extensions" \
  --install-extension "$RC64_VSIX" --force
code --user-data-dir "$RC64_HOME/user-data" --extensions-dir "$RC64_HOME/extensions" \
  "<local-home>/Documents/cnm/tasks/07_Stata-workbench"
```

The isolated profile settings must contain:

```json
{
  "stataMcp.visibleBridgePort": 17515,
  "stataMcp.restoreFinalSnapshotAfterGraphRouting": false
}
```

Hard gate:

```bash
curl -sS http://127.0.0.1:17515/status | jq '{extensionVersion,bundleId,bridgePort,patch,recovery,trueReady,terminalWebview}'
```

Required: version `0.1.3-rc.6.4.4`, bundle path under `.stata-workbench-rc644-profile/extensions`, port `17515`, patch `codex-rc64-control-plane`, and Terminal `fallbackActive=false`, `fallbackVersion=null`.

## Preserved-Tab Cold-Upgrade Gate

This gate reproduces the rc.6.4.1 regression and must not be replaced by opening a new Terminal panel:

1. Start from the isolated rc.6.4.1 profile with a `Stata Terminal` tab open.
2. Leave that tab open and fully quit the isolated VS Code application process. Killing only the Extension Host is insufficient.
3. Force-install the rc.6.4.4 VSIX into the same isolated profile, then reopen the same profile and workspace.
4. Do not close or recreate the restored Terminal tab. Let `registerWebviewPanelSerializer` restore it.
5. Require `/status.terminalWebview.panelExists=true`, `scriptReady=true`, `styleReady=true`, `fallbackActive=false`, `fallbackVersion=null`, `readyAt` non-null, and `bundleId` under the rc.6.4.4 installed extension directory.
6. Capture and inspect a macOS screenshot. Native unstyled buttons, missing fixed input layout, or a false readiness field fail this gate.

The isolated profile must remain on port `17515`; do not stop or modify the `17485`, `17495`, or `17505` profiles.

## Recovery Gate

1. Run the continuity-loss fixture through visible Human Run File and require `/status.continuityLost`.
2. `POST /force-reset`; require `recovery.required=true` and `trueReady=false`.
3. Record the recovery generation. `POST /graph-clear`; require the same generation and `recovery.required=true`.
4. While locked, ordinary terminal, selection, file, and `/run-command` probes must return quickly with `reasonCode=recovery-required` and HTTP `423` where HTTP applies.
5. `POST /recovery-smoke`; require `ok=true`, `rc=0`, `markerVerified=true`.
6. Require `/status.recovery.required=false` and `trueReady=true`, then query a variable created by the post-recovery setup run.
7. Compare `ownedBackendPids` and process snapshots before/after. No newly orphaned backend may remain.
8. Run `node scripts/mac/test_cleanup_unit.js`; then independently verify every reset-reported old PID is absent with `ps -p <pid>`. A zero cleanup exit code alone is not sufficient evidence.

## Regression Gate

- Human Run File PNG fixture: original `.do` SHA unchanged; fresh non-empty PNG produced through packaged Darwin helper.
- A2 Arm B (`restore=false`) and explicit Arm A (`restore=true`): verify variable continuity from Stata log output, not status text alone.
- Stop gate: capture `busy=true`, abort, verify progress stops, recover, then run a visible smoke.
- Quiet `/run-command` timing gate: run at least 20 seconds without intermediate output; HTTP must not return and `/status` must not become READY before the final Stata marker is present in the run log.
- Version/bundle/port and Terminal webview readiness probes remain correct after every reload.
- Run `npm run check` against the source tree and verify the installed VSIX contains both Mac helpers with executable mode and no backup/DS_Store files.

Only after these Mac gates pass should the exact same VSIX SHA move to the Windows acceptance checklist. Do not write “Windows + macOS supported” until both sides pass.
