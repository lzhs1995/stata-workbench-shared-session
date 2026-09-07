#!/usr/bin/env node
"use strict";

const assert = require("assert");
const childProcess = require("child_process");
const fs = require("fs");
const os = require("os");
const path = require("path");
const runtimePatch = require("./mcp_stata_runtime_patch");

const root = fs.mkdtempSync(path.join(os.tmpdir(), "mcp-stata-runtime-patch-"));
try {
  const compileSpawnSync = () => ({ status: 0, stdout: "", stderr: "" });
  const patchOptions = {
    runtimeRoot: root,
    pythonCommand: process.execPath,
    compileSpawnSync,
  };
  const backgroundNotifyFixture = [
    runtimePatch.ORIGINAL_BACKGROUND_NOTIFY_HEAD.trimEnd(),
    "            payload_to_send = text",
    runtimePatch.ORIGINAL_BACKGROUND_NOTIFY_SEND,
  ].join("\n");
  const graphCacheFixture = [
    runtimePatch.ORIGINAL_BACKGROUND_GRAPH_CACHE_COMMAND,
    runtimePatch.ORIGINAL_BACKGROUND_GRAPH_CACHE_DOFILE,
  ].join("\n");
  const streamTailFixture = [
    runtimePatch.ORIGINAL_STREAM_TAIL_SIGNATURE,
    runtimePatch.ORIGINAL_POST_DONE_DRAIN,
    runtimePatch.ORIGINAL_STREAM_CALL_TAIL,
    runtimePatch.ORIGINAL_STREAM_CALL_TAIL,
  ].join("\n");
  const backgroundGraphReadyFixture = [
    runtimePatch.ORIGINAL_BACKGROUND_GRAPH_READY_OPTION,
    runtimePatch.ORIGINAL_BACKGROUND_GRAPH_READY_OPTION,
  ].join("\n");
  const checkpointGraphReadyFixture = [
    runtimePatch.PATCHED_BACKGROUND_GRAPH_READY_OPTION,
    runtimePatch.PATCHED_BACKGROUND_GRAPH_READY_OPTION,
  ].join("\n");
  const backgroundSignaturesFixture = [
    runtimePatch.ORIGINAL_DOFILE_BACKGROUND_SIGNATURE,
    runtimePatch.ORIGINAL_COMMAND_BACKGROUND_SIGNATURE,
  ].join("\n");
  const packageDir = path.join(
    root,
    "lib",
    "python3.12",
    "site-packages",
    "mcp_stata"
  );
  fs.mkdirSync(packageDir, { recursive: true });
  const serverPath = path.join(packageDir, "server.py");
  const clientPath = path.join(packageDir, "stata_client.py");
  const graphDetectorPath = path.join(packageDir, "graph_detector.py");
  const sessionPath = path.join(packageDir, "sessions.py");
  fs.writeFileSync(
    serverPath,
    [
      "# fixture",
      runtimePatch.ORIGINAL_CALL_SYNC,
      runtimePatch.ORIGINAL_TASK_DONE_NOTIFY,
      backgroundNotifyFixture,
      backgroundNotifyFixture,
      backgroundSignaturesFixture,
      backgroundGraphReadyFixture,
      "# end",
    ].join("\n"),
    "utf8"
  );
  fs.writeFileSync(sessionPath, [
    "# fixture",
    runtimePatch.ORIGINAL_SESSION_CALL,
    "# end",
  ].join("\n"), "utf8");
  fs.writeFileSync(
    clientPath,
    [
      "# fixture",
      runtimePatch.ORIGINAL_STATA_BREAK_REQUEST,
      runtimePatch.ORIGINAL_STREAM_HELPER,
      runtimePatch.ORIGINAL_STREAM_NOTIFY,
      runtimePatch.ORIGINAL_FINAL_STREAM_NOTIFY,
      runtimePatch.ORIGINAL_STREAM_TAIL_SIGNATURE,
      runtimePatch.ORIGINAL_POST_DONE_DRAIN,
      runtimePatch.ORIGINAL_STREAM_CALL_TAIL,
      runtimePatch.ORIGINAL_STREAM_CALL_TAIL,
      runtimePatch.ORIGINAL_CLIENT_GRAPH_INVENTORY,
      runtimePatch.ORIGINAL_INTERNAL_SILENT_EXEC,
      graphCacheFixture,
      "# end",
    ].join("\n"),
    "utf8"
  );
  fs.writeFileSync(
    graphDetectorPath,
    [
      "# fixture",
      "class GraphCreationDetector:",
      runtimePatch.ORIGINAL_DETECTOR_GRAPH_DIR,
      runtimePatch.ORIGINAL_DETECTOR_GRAPH_DIR,
      runtimePatch.ORIGINAL_DETECTOR_GRAPH_DESCRIBE,
      "# end",
    ].join("\n"),
    "utf8"
  );

  const first = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(first.ok, true);
  assert.strictEqual(first.status, "applied");
  const firstBytes = fs.readFileSync(serverPath);
  assert.ok(firstBytes.toString("utf8").includes(runtimePatch.PATCH_MARKER));
  assert.ok(firstBytes.toString("utf8").includes("listener_task.get_loop()"));
  assert.ok(firstBytes.toString("utf8").includes("run_coroutine_threadsafe"));
  assert.ok(firstBytes.toString("utf8").includes(runtimePatch.TASK_DONE_PATCH_MARKER));
  assert.ok(firstBytes.toString("utf8").includes("await asyncio.wait_for("));
  assert.ok(firstBytes.toString("utf8").includes("timeout=0.25"));
  assert.ok(firstBytes.toString("utf8").includes("releasing transport"));
  const firstServerText = firstBytes.toString("utf8");
  assert.strictEqual(
    firstServerText.split(runtimePatch.LOG_PATH_NOTIFY_PATCH_MARKER).length - 1,
    2
  );
  assert.strictEqual(
    firstServerText.split(runtimePatch.CHECKPOINT_NOTIFY_PATCH_MARKER).length - 1,
    2
  );
  assert.strictEqual(
    firstServerText.split("workbench_quiet_checkpoint = (").length - 1,
    2
  );
  assert.strictEqual(
    firstServerText.split(runtimePatch.RESPECT_BACKGROUND_GRAPH_READY_PATCH_MARKER).length - 1,
    2
  );
  assert.ok(!firstServerText.includes(runtimePatch.ORIGINAL_BACKGROUND_GRAPH_READY_OPTION));
  assert.ok(!firstServerText.includes(runtimePatch.PATCHED_BACKGROUND_GRAPH_READY_OPTION));
  assert.strictEqual(
    firstServerText.split(runtimePatch.PATCHED_RESPECT_BACKGROUND_GRAPH_READY_OPTION).length - 1,
    2
  );
  assert.strictEqual(
    firstServerText.split('"emit_graph_ready": emit_graph_ready').length - 1,
    2
  );
  assert.strictEqual(
    firstServerText.split("emit_graph_ready: bool = True").length - 1,
    2
  );
  assert.ok(firstServerText.includes(
    '"___CODEX_CHECKPOINT_DONE___" in str(locals().get("code") or "")'));
  assert.strictEqual(
    firstServerText.split(runtimePatch.PATCHED_BACKGROUND_NOTIFY_SEND).length - 1,
    2
  );
  for (const block of firstServerText.split("    async def notify_log(text: str) -> None:").slice(1)) {
    assert.ok(
      block.indexOf("task_info.log_path = payload.get") <
        block.indexOf(runtimePatch.PATCHED_BACKGROUND_NOTIFY_SEND.trim()),
      "authoritative log_path must be recorded before the bounded notification"
    );
    assert.ok(
      block.indexOf(runtimePatch.CHECKPOINT_NOTIFY_PATCH_MARKER) <
        block.indexOf(runtimePatch.PATCHED_BACKGROUND_NOTIFY_SEND.trim()),
      "checkpoint output must be suppressed before the optional notification"
    );
  }
  const firstClientBytes = fs.readFileSync(clientPath);
  const firstClientText = firstClientBytes.toString("utf8");
  assert.ok(firstClientText.includes(runtimePatch.STATA_SET_BREAK_PATCH_MARKER));
  assert.ok(firstClientText.includes('getattr(pystata_config.stlib, "StataSO_SetBreak", None)'));
  assert.ok(firstClientText.includes("self._set_stata_break()"));
  assert.ok(!firstClientText.includes('getattr(sfi, "breakIn", None)'));
  assert.ok(firstClientText.includes(runtimePatch.STREAM_PATCH_MARKER));
  assert.ok(firstClientText.includes(runtimePatch.STREAM_TAIL_PATCH_MARKER));
  assert.ok(firstClientText.includes("required_tail_marker: Optional[str] = None"));
  assert.ok(firstClientText.includes(
    're.search(r"___CODEX_RUN_DONE_[A-Za-z0-9_.:-]+___", code)'));
  assert.ok(firstClientText.includes(
    're.search(r"___CODEX_RUN_DONE_[A-Za-z0-9_.:-]+___", dofile_text)'));
  assert.ok(firstClientText.includes("completion_deadline = time.monotonic() + 5.0"));
  assert.ok(firstClientText.includes('r"(?:^|\\n)(?:\\{(?:res|txt)\\})*"'));
  assert.ok(firstClientText.includes("if saw_required_tail or time.monotonic() >= completion_deadline:"));
  assert.ok(!firstClientText.includes(runtimePatch.ORIGINAL_POST_DONE_DRAIN));
  assert.ok(firstClientText.includes(
    'notice = "\\n[Stata Workbench: further progress available in log_path]\\n"'));
  assert.ok(firstClientText.includes("max_notify_chars = 4000"));
  assert.ok(firstClientText.includes("notify_budget_remaining = 4000"));
  assert.ok(firstClientText.includes(
    "nonlocal notifications_enabled, notify_budget_remaining"));
  assert.ok(firstClientText.includes("notify_budget_remaining -= len(piece)"));
  assert.ok(firstClientText.includes("await asyncio.wait_for("));
  assert.ok(firstClientText.includes("timeout=0.25"));
  assert.ok(firstClientText.includes("notifications_enabled = False"));
  assert.ok(firstClientText.includes(runtimePatch.GRAPH_PROBE_PATCH_MARKER));
  assert.ok(firstClientText.includes(runtimePatch.INTERNAL_SILENT_PATCH_MARKER));
  assert.strictEqual(
    firstClientText.split(runtimePatch.GRAPH_CACHE_DRAIN_PATCH_MARKER).length - 1,
    2
  );
  assert.ok(firstClientText.includes(runtimePatch.PATCHED_BACKGROUND_GRAPH_CACHE_COMMAND));
  assert.ok(firstClientText.includes(runtimePatch.PATCHED_BACKGROUND_GRAPH_CACHE_DOFILE));
  assert.ok(!firstClientText.includes(runtimePatch.ORIGINAL_BACKGROUND_GRAPH_CACHE_COMMAND));
  assert.ok(!firstClientText.includes(runtimePatch.ORIGINAL_BACKGROUND_GRAPH_CACHE_DOFILE));
  assert.ok(!firstClientText.includes("asyncio.create_task(\n                self._cache_new_graphs("));
  assert.ok(firstClientText.includes("capture quietly graph dir, memory"));
  assert.ok(firstClientText.includes("capture quietly graph describe `g'"));
  assert.ok(firstClientText.includes('f"capture quietly {inner_code}\\n"'));
  assert.ok(!firstClientText.includes('f"capture noisily {inner_code}\\n"'));
  assert.ok(firstClientText.indexOf("tee.write(cleaned_chunk)") <
    firstClientText.indexOf("await asyncio.wait_for("),
  "the complete visible log must be written before timeout-bounded MCP notifications");
  const firstGraphDetectorBytes = fs.readFileSync(graphDetectorPath);
  const firstGraphDetectorText = firstGraphDetectorBytes.toString("utf8");
  assert.ok(firstGraphDetectorText.includes(runtimePatch.GRAPH_PROBE_PATCH_MARKER));
  assert.strictEqual(
    firstGraphDetectorText.split(runtimePatch.PATCHED_DETECTOR_GRAPH_DIR).length - 1,
    2
  );
  assert.ok(firstGraphDetectorText.includes(runtimePatch.PATCHED_DETECTOR_GRAPH_DESCRIBE));
  const firstSessionBytes = fs.readFileSync(sessionPath);
  const firstSessionText = firstSessionBytes.toString("utf8");
  assert.ok(firstSessionText.includes(runtimePatch.SESSION_BREAK_DRAIN_PATCH_MARKER));
  assert.ok(firstSessionText.includes("return await asyncio.shield(future)"));
  assert.ok(firstSessionText.includes("while not future.done():"));
  assert.ok(!firstSessionText.includes("timeout=3.0"));
  assert.ok(!firstSessionText.includes("did not acknowledge break within timeout"));

  const second = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(second.ok, true);
  assert.strictEqual(second.status, "already-applied");
  assert.deepStrictEqual(fs.readFileSync(serverPath), firstBytes);
  assert.deepStrictEqual(fs.readFileSync(clientPath), firstClientBytes);
  assert.deepStrictEqual(fs.readFileSync(graphDetectorPath), firstGraphDetectorBytes);
  assert.deepStrictEqual(fs.readFileSync(sessionPath), firstSessionBytes);

  fs.writeFileSync(
    serverPath,
    [
      "# fixture",
      runtimePatch.PATCHED_CALL_SYNC,
      runtimePatch.ORIGINAL_TASK_DONE_NOTIFY,
      backgroundNotifyFixture,
      backgroundNotifyFixture,
      backgroundSignaturesFixture,
      backgroundGraphReadyFixture,
      "# end",
    ].join("\n"),
    "utf8"
  );
  const migratedServer = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(migratedServer.ok, true);
  assert.strictEqual(migratedServer.status, "applied");
  assert.strictEqual(migratedServer.serverStatus, "applied");
  assert.strictEqual(migratedServer.clientStatus, "already-applied");
  const migratedServerBytes = fs.readFileSync(serverPath);
  assert.ok(migratedServerBytes.toString("utf8").includes(runtimePatch.TASK_DONE_PATCH_MARKER));
  const migratedServerAgain = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(migratedServerAgain.status, "already-applied");
  assert.deepStrictEqual(fs.readFileSync(serverPath), migratedServerBytes);

  const legacyBackgroundNotifyFixture = [
    runtimePatch.PATCHED_BACKGROUND_NOTIFY_HEAD_V1.trimEnd(),
    "            payload_to_send = text",
    runtimePatch.PATCHED_BACKGROUND_NOTIFY_SEND,
  ].join("\n");
  fs.writeFileSync(
    serverPath,
    [
      "# fixture",
      runtimePatch.PATCHED_CALL_SYNC,
      runtimePatch.PATCHED_TASK_DONE_NOTIFY,
      legacyBackgroundNotifyFixture,
      legacyBackgroundNotifyFixture,
      backgroundSignaturesFixture,
      checkpointGraphReadyFixture,
      "# end",
    ].join("\n"),
    "utf8"
  );
  const migratedCheckpointNotify = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(migratedCheckpointNotify.ok, true);
  assert.strictEqual(migratedCheckpointNotify.status, "applied");
  const migratedCheckpointBytes = fs.readFileSync(serverPath);
  assert.ok(migratedCheckpointBytes.toString("utf8").includes(
    runtimePatch.CHECKPOINT_NOTIFY_PATCH_MARKER));
  const migratedCheckpointAgain = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(migratedCheckpointAgain.status, "already-applied");
  assert.deepStrictEqual(fs.readFileSync(serverPath), migratedCheckpointBytes);

  fs.writeFileSync(
    clientPath,
    [
      "# fixture",
      runtimePatch.PATCHED_STATA_BREAK_REQUEST,
      runtimePatch.PATCHED_STREAM_HELPER_V18,
      runtimePatch.PATCHED_STREAM_NOTIFY,
      runtimePatch.PATCHED_FINAL_STREAM_NOTIFY,
      streamTailFixture,
      runtimePatch.ORIGINAL_CLIENT_GRAPH_INVENTORY,
      runtimePatch.ORIGINAL_INTERNAL_SILENT_EXEC,
      graphCacheFixture,
      "# end",
    ].join("\n"),
    "utf8"
  );
  const migratedV18 = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(migratedV18.ok, true);
  assert.strictEqual(migratedV18.status, "applied");
  assert.strictEqual(migratedV18.serverStatus, "already-applied");
  assert.strictEqual(migratedV18.clientStatus, "applied");
  const migratedV18Bytes = fs.readFileSync(clientPath);
  const migratedV18Text = migratedV18Bytes.toString("utf8");
  assert.ok(migratedV18Text.includes(runtimePatch.STREAM_PATCH_MARKER));
  assert.ok(!migratedV18Text.includes(runtimePatch.STREAM_PATCH_MARKER_V18));
  const migratedV18Again = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(migratedV18Again.status, "already-applied");
  assert.deepStrictEqual(fs.readFileSync(clientPath), migratedV18Bytes);

  fs.writeFileSync(
    clientPath,
    [
      "# fixture",
      runtimePatch.PATCHED_STATA_BREAK_REQUEST,
      runtimePatch.PATCHED_STREAM_HELPER_V17,
      runtimePatch.PATCHED_STREAM_NOTIFY,
      runtimePatch.PATCHED_FINAL_STREAM_NOTIFY,
      streamTailFixture,
      runtimePatch.ORIGINAL_CLIENT_GRAPH_INVENTORY,
      runtimePatch.ORIGINAL_INTERNAL_SILENT_EXEC,
      graphCacheFixture,
      "# end",
    ].join("\n"),
    "utf8"
  );
  const migrated = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(migrated.ok, true);
  assert.strictEqual(migrated.status, "applied");
  assert.strictEqual(migrated.serverStatus, "already-applied");
  assert.strictEqual(migrated.clientStatus, "applied");
  const migratedClientBytes = fs.readFileSync(clientPath);
  const migratedClientText = migratedClientBytes.toString("utf8");
  assert.ok(migratedClientText.includes(runtimePatch.STREAM_PATCH_MARKER));
  assert.ok(!migratedClientText.includes(runtimePatch.STREAM_PATCH_MARKER_V17));
  const migratedAgain = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(migratedAgain.status, "already-applied");
  assert.deepStrictEqual(fs.readFileSync(clientPath), migratedClientBytes);

  fs.writeFileSync(
    clientPath,
    [
      "# fixture",
      runtimePatch.PATCHED_STATA_BREAK_REQUEST,
      runtimePatch.PATCHED_STREAM_HELPER_V19,
      runtimePatch.PATCHED_STREAM_NOTIFY,
      runtimePatch.PATCHED_FINAL_STREAM_NOTIFY,
      streamTailFixture,
      runtimePatch.ORIGINAL_CLIENT_GRAPH_INVENTORY,
      runtimePatch.ORIGINAL_INTERNAL_SILENT_EXEC,
      graphCacheFixture,
      "# end",
    ].join("\n"),
    "utf8"
  );
  const migratedV19 = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(migratedV19.ok, true);
  assert.strictEqual(migratedV19.status, "applied");
  assert.strictEqual(migratedV19.clientStatus, "applied");
  const migratedV19Text = fs.readFileSync(clientPath, "utf8");
  assert.ok(migratedV19Text.includes(runtimePatch.STREAM_PATCH_MARKER));
  assert.ok(!migratedV19Text.includes(runtimePatch.STREAM_PATCH_MARKER_V19));
  assert.ok(migratedV19Text.includes(
    'notice = "\\n[Stata Workbench: further progress available in log_path]\\n"'));
  const migratedV19Again = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(migratedV19Again.status, "already-applied");

  fs.writeFileSync(serverPath, "# incompatible upstream\n", "utf8");
  const refused = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(refused.ok, false);
  assert.strictEqual(refused.status, "unsupported-source");
  assert.strictEqual(fs.readFileSync(serverPath, "utf8"), "# incompatible upstream\n");

  fs.writeFileSync(serverPath, firstServerText, "utf8");
  fs.writeFileSync(sessionPath, "# incompatible session upstream\n", "utf8");
  const sessionRefused = runtimePatch.patchRuntime(patchOptions);
  assert.strictEqual(sessionRefused.ok, false);
  assert.strictEqual(sessionRefused.status, "unsupported-source");
  assert.strictEqual(sessionRefused.component, "session");
  assert.strictEqual(fs.readFileSync(sessionPath, "utf8"), "# incompatible session upstream\n");
  fs.writeFileSync(sessionPath, firstSessionText, "utf8");

  const command = path.join(root, "bin", "mcp-stata");
  assert.strictEqual(runtimePatch.runtimeRootFromCommand(command), root);
  const uvRoot = runtimePatch.runtimeRootFromUvCommand("uvx", {
    spawnSync: (commandName, args) => ({
      status: commandName === "uvx" && args.includes("mcp-stata==1.26.1") ? 0 : 1,
      stdout: `${root}\n`,
      stderr: "",
    }),
  });
  assert.strictEqual(uvRoot, root);
  const uvFirst = runtimePatch.candidateRuntimeRoots({
    uvCommand: "uvx",
    command,
    spawnSync: () => ({ status: 0, stdout: `${root}\n`, stderr: "" }),
  });
  assert.strictEqual(uvFirst[0], root);

  const precedenceHome = fs.mkdtempSync(path.join(os.tmpdir(), "mcp-stata-precedence-"));
  const configuredRoot = path.join(precedenceHome, "configured");
  const envRoot = path.join(precedenceHome, "env");
  const fixedRoot = path.join(
    precedenceHome,
    ".local",
    "share",
    "stata-workbench",
    "mcp-stata-1.26.1"
  );
  const uvRuntimeRoot = path.join(precedenceHome, "uv-cache");
  const ordered = runtimePatch.candidateRuntimeRoots({
    runtimeRoot: path.join(precedenceHome, "explicit"),
    command: path.join(configuredRoot, "bin", "mcp-stata"),
    env: { MCP_STATA_RUNTIME_ROOT: envRoot },
    homedir: precedenceHome,
    uvRuntimeRoot,
    uvCommand: "uvx",
    spawnSync: () => ({
      status: 0,
      stdout: `${path.join(precedenceHome, "uv-discovered")}\n`,
      stderr: "",
    }),
  });
  assert.deepStrictEqual(ordered.slice(0, 5), [
    path.join(precedenceHome, "explicit"),
    configuredRoot,
    envRoot,
    fixedRoot,
    path.join(precedenceHome, "AppData", "Local", "stata-workbench", "mcp-stata-1.26.1"),
  ].map((entry) => path.resolve(entry)));
  assert.ok(ordered.indexOf(path.resolve(fixedRoot)) < ordered.indexOf(path.resolve(uvRuntimeRoot)));

  const realPython = process.execPath;
  const validCompile = runtimePatch.compilePythonSources(root, [
    { path: "valid.py", source: "value = 1\n" },
  ], { pythonCommand: realPython });
  assert.strictEqual(validCompile.ok, false);
  assert.strictEqual(validCompile.status, "python-compile-failed");

  const hostPython = [process.env.PYTHON, "python3", "python"]
    .filter(Boolean)
    .find((candidate) => {
      const probe = childProcess.spawnSync(candidate, ["-I", "-c", "compile('x = 1', 'probe.py', 'exec')"]);
      return probe && probe.status === 0;
    });
  assert.ok(hostPython, "a host Python interpreter is required for syntax-gate tests");
  const breakBehaviorSource = `
import logging
import sys
import types

calls = []
def set_break():
    calls.append("break")

pystata = types.ModuleType("pystata")
pystata.config = types.SimpleNamespace(
    stlib=types.SimpleNamespace(StataSO_SetBreak=set_break)
)
sys.modules["pystata"] = pystata
logger = logging.getLogger("test")

class Client:
${runtimePatch.PATCHED_STATA_BREAK_REQUEST}

client = Client()
client._break_requested = False
client._request_break_in()
assert client._break_requested is True
client._request_break_in_fast()
assert calls == ["break", "break"], calls
`;
  const breakBehavior = childProcess.spawnSync(
    hostPython,
    ["-I", "-c", breakBehaviorSource],
    { encoding: "utf8", timeout: 5000 }
  );
  assert.strictEqual(
    breakBehavior.status,
    0,
    `supported Stata break behavior failed: ${breakBehavior.stderr || breakBehavior.stdout}`
  );
  const drainBody = runtimePatch.PATCHED_POST_DONE_DRAIN
    .split("\n")
    .map((line) => line.startsWith("        ") ? line.slice(8) : line)
    .join("\n");
  const behaviorSource = `
import asyncio
import re

class Clock:
    value = 0.0

class FakeTime:
    @staticmethod
    def monotonic():
        return Clock.value

class FakeThread:
    @staticmethod
    async def run_sync(fn):
        return fn()

class FakeAnyio:
    to_thread = FakeThread()

    @staticmethod
    async def sleep(seconds):
        Clock.value += seconds

class Cleaner:
    def _clean_internal_smcl(self, chunk, **_kwargs):
        return chunk

time = FakeTime()
anyio = FakeAnyio()

async def exercise(chunks, required_tail_marker, pre_done_chunks=None):
    self = Cleaner()
    last_pos = 0
    has_written = False
    on_chunk = None
    tee = []
    calls = 0
    tail_marker_buffer = ""
    saw_required_tail = required_tail_marker is None
    tail_marker_line = (
        re.compile(
            r"(?:^|\\n)(?:\\{(?:res|txt)\\})*"
            + re.escape(required_tail_marker)
            + r"\\s*(?:\\n|$)"
        )
        if required_tail_marker
        else None
    )

    def _read_content():
        nonlocal calls
        calls += 1
        if chunks:
            value = chunks.pop(0)
            return value, len(value.encode("utf-8"))
        return "", 0

    async def _write_and_notify(cleaned_chunk, _label):
        nonlocal tail_marker_buffer, saw_required_tail
        tee.append(cleaned_chunk)
        if tail_marker_line and not saw_required_tail:
            tail_marker_buffer = (tail_marker_buffer + "\\n" + cleaned_chunk)[-8192:]
            if tail_marker_line.search(tail_marker_buffer):
                saw_required_tail = True

    for pre_done_chunk in pre_done_chunks or []:
        await _write_and_notify(pre_done_chunk, "notify_log")

${drainBody}
    return saw_required_tail, "".join(tee), calls, Clock.value

async def main():
    marker = "___CODEX_RUN_DONE_run_behavior___"
    echo = '. display as text "' + marker + '"\\n'
    result = "{res}{txt}" + marker + "\\n"

    Clock.value = 0.0
    verified = await exercise([echo, "", "business-tail\\n", result], marker)
    assert verified[0] is True, verified
    assert "business-tail" in verified[1], verified
    assert verified[2] >= 5, verified
    assert verified[3] < 5.0, verified

    Clock.value = 0.0
    already_seen = await exercise([], marker, [result])
    assert already_seen[0] is True, already_seen
    assert already_seen[2] == 1, already_seen
    assert already_seen[3] == 0.0, already_seen

    Clock.value = 0.0
    echo_only = await exercise([echo], marker)
    assert echo_only[0] is False, echo_only
    assert echo_only[2] >= 100, echo_only
    assert echo_only[3] >= 5.0, echo_only

    Clock.value = 0.0
    absent = await exercise(["business-tail-without-marker\\n"], marker)
    assert absent[0] is False, absent
    assert absent[3] >= 5.0, absent

asyncio.run(main())
`;
  const behavior = childProcess.spawnSync(
    hostPython,
    ["-I", "-c", behaviorSource],
    { encoding: "utf8", timeout: 15000 }
  );
  assert.strictEqual(
    behavior.status,
    0,
    `patched post-done drain behavior failed: ${behavior.stderr || behavior.stdout}`
  );
  const realValidCompile = runtimePatch.compilePythonSources(root, [
    { path: "valid.py", source: "value = 1\n" },
  ], { pythonCommand: hostPython });
  assert.strictEqual(realValidCompile.ok, true);
  const invalidCompile = runtimePatch.compilePythonSources(root, [
    { path: "invalid.py", source: "value = \"\n" },
  ], { pythonCommand: hostPython });
  assert.strictEqual(invalidCompile.ok, false);
  assert.strictEqual(invalidCompile.status, "python-compile-failed");
  assert.ok(invalidCompile.stderr.includes("SyntaxError"));

  fs.writeFileSync(serverPath, firstServerText, "utf8");
  fs.writeFileSync(clientPath, firstClientText.replace(
    runtimePatch.STREAM_PATCH_MARKER,
    runtimePatch.STREAM_PATCH_MARKER_V19
  ).replace(
    'notice = "\\n[Stata Workbench: further progress available in log_path]\\n"',
    'notice = "\n[Stata Workbench: further progress available in log_path]\n"'
  ), "utf8");
  fs.writeFileSync(graphDetectorPath, firstGraphDetectorText, "utf8");
  fs.writeFileSync(sessionPath, firstSessionText, "utf8");
  const corruptBefore = [serverPath, clientPath, graphDetectorPath, sessionPath].map(
    (file) => fs.readFileSync(file)
  );
  let rejectedCandidateHadFixedNotice = false;
  const syntaxRefused = runtimePatch.patchRuntime({
    runtimeRoot: root,
    pythonCommand: process.execPath,
    compileSpawnSync(commandName, args, options) {
      const sources = JSON.parse(options.input);
      const client = sources.find((entry) => entry.path === clientPath);
      rejectedCandidateHadFixedNotice = Boolean(client && client.source.includes(
        'notice = "\\n[Stata Workbench: further progress available in log_path]\\n"'
      ));
      return {
        status: 1,
        stdout: "",
        stderr: "SyntaxError: injected candidate compilation failure",
      };
    },
  });
  assert.strictEqual(syntaxRefused.ok, false);
  assert.strictEqual(syntaxRefused.status, "pre-write-compile-failed");
  assert.strictEqual(syntaxRefused.compile.status, "python-compile-failed");
  assert.strictEqual(rejectedCandidateHadFixedNotice, true);
  [serverPath, clientPath, graphDetectorPath, sessionPath].forEach((file, index) => {
    assert.deepStrictEqual(fs.readFileSync(file), corruptBefore[index]);
  });

  fs.writeFileSync(serverPath, firstServerText, "utf8");
  fs.writeFileSync(
    clientPath,
    firstClientText
      .replace(runtimePatch.STREAM_PATCH_MARKER, runtimePatch.STREAM_PATCH_MARKER_V19)
      .replace(
        'notice = "\\n[Stata Workbench: further progress available in log_path]\\n"',
        'notice = "\n[Stata Workbench: further progress available in log_path]\n"'
      ),
    "utf8"
  );
  fs.writeFileSync(
    graphDetectorPath,
    [
      "# fixture",
      "class GraphCreationDetector:",
      runtimePatch.ORIGINAL_DETECTOR_GRAPH_DIR,
      runtimePatch.ORIGINAL_DETECTOR_GRAPH_DIR,
      runtimePatch.ORIGINAL_DETECTOR_GRAPH_DESCRIBE,
      "# end",
    ].join("\n"),
    "utf8"
  );
  fs.writeFileSync(sessionPath, runtimePatch.ORIGINAL_SESSION_CALL, "utf8");
  const transactionBefore = [serverPath, clientPath, graphDetectorPath, sessionPath].map(
    (file) => fs.readFileSync(file)
  );
  let writeCalls = 0;
  const rolledBack = runtimePatch.patchRuntime({
    runtimeRoot: root,
    pythonCommand: process.execPath,
    compileSpawnSync,
    atomicWrite(file, content) {
      writeCalls += 1;
      if (writeCalls === 1) {
        runtimePatch.atomicWrite(file, content);
        return;
      }
      if (writeCalls === 2) throw new Error("injected second write failure");
      runtimePatch.atomicWrite(file, content);
    },
  });
  assert.strictEqual(rolledBack.ok, false);
  assert.strictEqual(rolledBack.status, "write-transaction-rolled-back");
  assert.strictEqual(rolledBack.rollbackOk, true);
  assert.ok(writeCalls >= 6, "rollback must rewrite all four original files");
  [serverPath, clientPath, graphDetectorPath, sessionPath].forEach((file, index) => {
    assert.deepStrictEqual(fs.readFileSync(file), transactionBefore[index]);
  });

  function writePatchedRuntime(runtimeRoot) {
    const runtimePackage = path.join(
      runtimeRoot,
      "lib",
      "python3.12",
      "site-packages",
      "mcp_stata"
    );
    fs.mkdirSync(runtimePackage, { recursive: true });
    fs.writeFileSync(path.join(runtimePackage, "server.py"), firstServerText, "utf8");
    fs.writeFileSync(path.join(runtimePackage, "stata_client.py"), firstClientText, "utf8");
    fs.writeFileSync(
      path.join(runtimePackage, "graph_detector.py"),
      firstGraphDetectorText,
      "utf8"
    );
    fs.writeFileSync(
      path.join(runtimePackage, "sessions.py"),
      firstSessionText,
      "utf8"
    );
  }
  writePatchedRuntime(fixedRoot);
  writePatchedRuntime(uvRuntimeRoot);
  const selected = runtimePatch.patchRuntime({
    homedir: precedenceHome,
    env: {},
    uvRuntimeRoot,
    pythonCommand: process.execPath,
    compileSpawnSync,
  });
  assert.strictEqual(selected.ok, true);
  assert.strictEqual(selected.root, path.resolve(fixedRoot));
  assert.notStrictEqual(selected.root, path.resolve(uvRuntimeRoot));
  console.log("MCP_STATA_RUNTIME_PATCH_RC7_PASS");
} finally {
  fs.rmSync(root, { recursive: true, force: true });
}
