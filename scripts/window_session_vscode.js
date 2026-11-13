"use strict";

const path = require("node:path");
const { createWindowSession, configuredPort, configuredRuntimeRoot } = require("./window_session_core");

// Thin VS Code adapter. Configuration is scoped to this client instance;
// process.env and the user's global/workspace settings are never rewritten.
function install(context, vscode, client, options = {}) {
  const folders = vscode.workspace.workspaceFolders || [];
  if (vscode.env.remoteName || folders.some((folder) => folder.uri.scheme !== "file")) {
    throw new Error("This release supports local Mac/Windows windows; remote extension hosts are not yet validated.");
  }
  const cfg = vscode.workspace.getConfiguration("stataMcp");
  const originalLoad = client._loadServerConfig.bind(client);
  const originalEnsure = client._ensureClient.bind(client);
  client._pypiVersion = "1.26.1";
  if (context.extension && context.extension.packageJSON) client._clientVersion = context.extension.packageJSON.version;
  const manager = createWindowSession({
    ...options,
    minimumFreeDiskGiB: cfg.get ? cfg.get("minimumFreeDiskGiB", 0) : 0,
    workspacePath: folders[0] && folders[0].uri.fsPath,
    // Read when the session starts, so a corrected setting applies without reinstalling.
    windowRuntimeRoot: () => configuredRuntimeRoot(vscode.workspace.getConfiguration("stataMcp", folders[0] && folders[0].uri)),
    label: "stata",
    patchRuntime: options.patchRuntime || ((input) => require("./mcp_stata_runtime_patch").patchRuntime(input)),
    onState: (state) => {
      try { client._log(`[Workbench ${state.sessionName}] ${state.phase}`); } catch {}
      if (options.onState) options.onState(state);
    },
  });
  manager.requestedPort = configuredPort(cfg);
  client._loadServerConfig = (...args) => manager.getConfig() || originalLoad(...args);
  client._ensureClient = async (...args) => {
    await manager.prepare(originalLoad({ hostOnly: true }));
    if (manager.status().closing) throw new Error("SESSION_CLOSING");
    manager.mark("connecting");
    try { const connected = await originalEnsure(...args); if (!manager.status().closing) manager.mark("ready"); return connected; }
    catch (error) { if (!manager.status().closing) manager.mark("error"); throw error; }
  };
  const start = vscode.commands.registerCommand("stata-workbench.startSession", async () => {
    try {
      await client.connect();
      await vscode.commands.executeCommand("stata-workbench.openTerminal");
    } catch (error) { vscode.window.showErrorMessage(`Stata Workbench: ${error.message}`); }
  });
  context.subscriptions.push(start, { dispose: () => manager.beginClose() });
  require("./window_session_status").install(vscode, manager, context);
  manager.registryFields = () => ({ ...manager.status(),
    ordinaryWindow: true, extensionPath: context.extensionUri.fsPath,
    profilePath: path.join(manager.stateRoot, "runs", manager.sessionId),
    runtime: { configPath: manager.getConfig() && manager.getConfig().configPath, source: manager.getRuntimeSource() },
    dirs: { tempDir: manager.dirs.tmp, checkpointDir: manager.dirs.checkpoints,
      logDir: manager.dirs["mcp-temp"], graphDir: manager.dirs["mcp-temp"] },
  });
  return manager;
}

module.exports = { install };
