"use strict";

function describe(manager, store = globalThis) {
  const window = manager.status(), bridge = store.__codexBridgeState || {};
  const recovery = store.__codexRecoveryState || {};
  const stop = store.__codexLastSoftStop || {};
  let phase = window.phase, actor = null;
  if (window.closing) phase = window.phase;
  else if (store.__codexSoftStopInFlight) phase = "stopping";
  else if (recovery.required) phase = "recovery required";
  else if (bridge.busy) { phase = "running"; actor = bridge.agentName || bridge.source || null; }
  else if (store.__codexEditGate?.pending().some(r => r && ["pending", "applying"].includes(r.status))) phase = "review edit";
  else if (bridge.postRunBusy) phase = "settling";
  else if (stop.ok && stop.restored && bridge.lastCompletedRun?.runId === stop.runId) phase = "paused";
  const text = `${window.sessionName}: ${phase}${actor ? " · " + String(actor).slice(0,40) : ""}`;
  return { text: "$(beaker) Stata · " + text, phase,
    tooltip: `Session ${window.sessionId}\n${window.workspacePath || "No folder opened"}\n${window.lastError || "Open this window's Stata Terminal"}` };
}

function install(vscode, manager, context, options = {}) {
  const bar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 35);
  bar.command = "stata-workbench.openTerminal";
  const update = () => {
    try { const view = describe(manager, options.store || globalThis); bar.text = view.text; bar.tooltip = view.tooltip; bar.show(); }
    catch { bar.text = "$(warning) Stata · status unavailable"; bar.show(); }
  };
  const interval = (options.setInterval || setInterval)(update, 750);
  interval.unref?.();
  context.subscriptions.push(bar, { dispose() { (options.clearInterval || clearInterval)(interval); } });
  update();
  return update;
}

module.exports = { describe, install };
