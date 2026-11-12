# Stata Workbench 共享会话

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

<img src="media/icon.png" alt="Stata Workbench 共享会话图标" width="96">

> **0.2.0 候选版——正在交付，尚未发布。** 下述普通窗口流程针对本候选版。
> 精确安装包的安装、实机验收及实际 Codex/Claude 宿主交互仍需完成。
> 下方保留的 Next 历史结果不能证明这些检查已通过。

在 VS Code 里，让人和 AI agent 共用一个看得见的 Stata 会话。模型运行时可以看输出、按 Stop、
审阅代码修改提议，再决定运行哪个已保存阶段。数据、宏、标量、估计结果和图在会话内共享；
关闭或重置前，请保存需要保留的结果。

- **两个独立分析窗口。** 在普通 VS Code 窗口中手动启动最多两个会话，包括同一配置中的两个窗口。
  每个会话有自己的 Stata 后端、端口、运行时、临时文件和检查点。
- **可见的协作。** 人和 agent 在一个会话内轮流运行；不同会话可以并行跑不同模型。
- **人审阅后才改稿。** agent 通过 diff 提议修改 `.do`、`.ado` 或 `.mata`。
  Accept 只写入文件；继续执行需要新的用户指令。
- **回执与明确的恢复。** 执行结果不明时不自动重试；恢复失败后会话保持阻塞。

派生自 [tmonk/stata-workbench](https://github.com/tmonk/stata-workbench)
（AGPL-3.0-or-later），见[许可](#许可)。

## 项目导航

| 仓库 | 角色 |
| --- | --- |
| [Shared Session](https://github.com/lzhs1995/stata-workbench-shared-session) | 运行时主线与版本发布 |
| [操作技能](https://github.com/lzhs1995/stata-workbench-shared-session-skill) | 独立版本的 agent 操作指南与运行时兼容检查 |
| [Next](https://github.com/lzhs1995/stata-workbench-next) | 开发分支与历史预览版证据 |

三个仓库各自维护版本。请使用兼容记录明确指定的运行时和操作技能；Next 仍是独立预览分支，
不会替换现有研究会话。

## 目录

- [候选版身份](#候选版身份)与[环境要求](#环境要求)
- [安装](#安装)与[快速上手](#快速上手)
- [Agent 日常流程](docs/agent-daily-workflow.md)与[AGENTS.md](AGENTS.md)
- [功能](#功能)、[配置](#配置)、[排错](#排错)
- [已知限制](#已知限制)与[平台实测结果](#平台实测结果)
- [开发](#开发)与[许可](#许可)

## 候选版身份

| 项目 | 0.2.0 候选版 |
| --- | --- |
| 扩展 ID | `lzhs1995.stata-workbench-shared-session` |
| 手动入口 | 在目标普通窗口运行 **Stata: Start Shared Session** |
| 状态根目录 | `~/.stata-workbench`，可由 `STATA_WORKBENCH_HOME` 覆盖 |
| 注册表 | `<state-root>/sessions/<sessionId>.json` |
| 本地端口 | 自动分配，通过注册表发现 |
| 并发 | 最多两个独立会话；每个会话一次只运行一个请求 |
| Agent 客户端 | 已安装扩展内的 `tools/workbench_agent.py` |

Next 仍是开发分支。它的隔离启动器、五会话测试、`~/.stata-workbench-next` 根目录和扩展 ID
属于历史预览版，不是普通窗口的设置步骤。操作技能独立版本化；旧 rc.7.45 兼容记录不能认证 0.2.0。
不要在目标窗口同时启用 Shared Session 与 Next。

## 环境要求

使用本机 macOS 或 Windows 窗口、已授权的 Stata、VS Code 1.75 或更高版本，以及运行内附
agent 工具所需的 Python 3.10 或更高版本。还须先准备匹配的 Stata 服务运行时：Python 3.11、
`mcp-stata==1.26.1` 和兼容的 MCP 1.x（仓库约束固定为 `mcp==1.28.1`）。
装好 VSIX 不能证明这些依赖已存在或可用。

运行时通常位于 macOS 的 `~/.local/share/stata-workbench/mcp-stata-1.26.1`，或 Windows 的
`%LOCALAPPDATA%\stata-workbench\mcp-stata-1.26.1`。显式绝对路径 `MCP_STATA_RUNTIME_ROOT`
或已配置的服务 Python 可选择其他来源。每个启动的窗口都会准备自己的运行时副本。
复制**之后**，macOS 至少保留 20 GiB、Windows 至少保留 10 GiB 可用空间；不足时拒绝启动。
这些是候选版要求，不是当前实机测试已通过的声明。

## 安装

1. 从交付负责人处取得本地提供、已审阅的 `stata-workbench-shared-session-0.2.0.vsix`
   及其精确 SHA256。目前不提供尚未确认的 0.2.0 公开发布地址。
   macOS 使用 `shasum -a 256 /absolute/path/to/file.vsix`；Windows 使用
   `(Get-FileHash 'C:\absolute\path\file.vsix' -Algorithm SHA256).Hash.ToLower()`。
   安装前，将完整值与已审阅交付记录核对。
2. 在准备使用的普通 VS Code 配置中，选择 **Extensions → Install from VSIX…**，选取该文件。
   使用目标窗口；如果安装要求重载，先完成正在进行的工作并保存数据。
   安装成功不等于已激活、依赖已准备好或实机已就绪。
3. 打开本地项目文件夹，仅对自己信任的文件夹授予 workspace trust。
   将 `stataMcp.loadStataOnStartup` 保持为 **false**，包括继承的用户或工作区设置。
   找不到 Stata 时，配置 `stataMcp.stataPath`。
4. 在命令面板手动运行 **Stata: Start Shared Session**。它连接本窗口的会话并打开 Terminal。
   打开无关窗口不得自动启动引擎。要运行第二个独立模型，另开一个普通窗口并在那里启动，
   不需要专用启动器或配置目录。

运行时缺失或不匹配时，停在报告的设置错误处，准备好匹配运行时后再 Start。
本候选版不声称会自动安装依赖，也不声称已经完成全新机器的安装验收。

## 快速上手

人可以使用 **Stata: Run Current File**（macOS `Cmd+Shift+D`，Windows `Ctrl+Shift+D`）、
**Stata: Run Selection/Current Line** 或 Stata Terminal，并在该窗口查看运行输出和身份。

Shell agent 使用已安装扩展内附的工具。Code CLI 在 PATH 中时，macOS 上这样发现会话：

```sh
WB_EXTENSION="$(code --locate-extension lzhs1995.stata-workbench-shared-session)"
WB_AGENT="$WB_EXTENSION/tools/workbench_agent.py"
python3 -B "$WB_AGENT" sessions
```

Windows PowerShell，先选定已安装的 Python 路径：

```powershell
$WbPython = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python314\python.exe'
$WbExtension = (code --locate-extension lzhs1995.stata-workbench-shared-session).Trim()
$WbAgent = Join-Path $WbExtension 'tools\workbench_agent.py'
if (-not (Test-Path $WbPython) -or -not (Test-Path $WbAgent)) { throw 'Check Python and the installed Workbench path' }
& $WbPython -B $WbAgent sessions
```

使用与目标配置匹配的安装目录，不要随意取某个源码 checkout。按人的工作区与窗口选择精确的
`sessionId`。把 `SESSION_ID` 和 `/abs/...` 替换为实际值：源码必须已保存且位于该工作区内，
每次使用新的 workflow 目录。Windows 在 `& $WbPython -B $WbAgent` 后使用相同参数，
路径替换为 Windows 绝对路径。

```sh
python3 -B "$WB_AGENT" status --session SESSION_ID
python3 -B "$WB_AGENT" run --session SESSION_ID --file /abs/project/stage01.do --cwd /abs/project --workflow-dir /abs/receipts/stage01 --agent-name Codex
python3 -B "$WB_AGENT" status --workflow /abs/receipts/stage01
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01
```

Claude Code 使用 `--agent-name 'Claude Code'`。`run` 启动本地 worker 后就返回，agent 可继续接收
用户指令。查询或提交的退出码 0 不等于执行 PASS：检查 `state` 和原回执的 `verdict`。
只有 `PASS_VISIBLE_SHARED_RUN` 才确认经检查的执行完成；统计结论仍须审阅输出。
执行不明时不得重新提交。回执包含私有源码和输出，请保存在本地。

人说“stop it”时：

```sh
python3 -B "$WB_AGENT" stop --workflow /abs/receipts/stage01 --user-action 'stop it'
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01
```

持续观察原 workflow，直到确认暂停、恢复及就绪。仅取消 agent 宿主操作不会停止 Workbench worker；
已经写出的外部文件也不会撤销。原运行尚不可见时允许怎样有限地重试 Stop，见
[日常流程](docs/agent-daily-workflow.md)。

<a id="agent-改-stata-文件要经人审阅"></a>

把提议的新文本放在独立文件中，不要先覆盖目标文件：

```sh
python3 -B "$WB_AGENT" propose-edit --workflow /abs/receipts/stage01 --content-file /abs/proposals/stage01-proposed.txt --reason 'Apply the requested model change'
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01 --proposal-id RETURNED_PROPOSAL_ID
```

提议的目标是该 workflow 的原始源码。人在 diff 中选择 **Accept** 或 **Reject**。
如果人改的是原缓冲区，先让其保存，再提交新提议；未保存、版本或 SHA 冲突会拒绝旧提议。
**Accept 只写入文件。** 已确认暂停后，新的用户指令可以明确选择要继续的已保存阶段：

```sh
python3 -B "$WB_AGENT" continue --workflow /abs/receipts/stage01 --file /abs/project/stage03.do --workflow-dir /abs/receipts/stage03-continued --user-action 'Continue only the saved stage03.do'
```

它只运行所选文件，**从文件开头执行**，沿用父 workflow 的工作目录，不会猜测从哪一行恢复。
分阶段任务一次提交一个文件，检查每个回执；先处理未保存修改，再运行下一阶段。
结束时保存所需数据，通过 VS Code 关闭目标窗口；不要为关闭一个会话而结束共用的 Code 进程。

## 功能

每个会话让人和 agent 共享 Stata 状态与实时输出，内部串行执行。目标忙时不会改投另一个窗口。
私有注册表和经鉴权的 bridge 绑定会话、generation 与已安装 bundle。
内附 CLI 提供 `sessions`、`status`、`run`、`stop`、`propose-edit`、`reconcile`、`continue`。

修改提议检查工作区真实路径、未保存缓冲区、文档版本和文件 SHA，保留原文件快照并设有有效期。
Accept 不执行。agent 修改 Stata 源码必须走此流程；这些宿主指令本身不是操作系统写入沙箱。

Stop 尝试恢复 agent 运行前的检查点，人的运行可能没有检查点。恢复失败后会话保持阻塞。
**Stata: KILL** 是独立的恢复操作，可能丢失内存数据，必须取得知情确认；清理结果不明不能报成干净。

## 配置

| 设置 | 当前普通窗口用法 |
| --- | --- |
| `stataMcp.loadStataOnStartup` | 保持 `false`，手动启动 |
| `stataMcp.visibleBridgePort` | `0` 自动分配；显式端口必须唯一 |
| `stataMcp.stataPath` | 需要时指定本机已授权的 Stata 可执行文件 |
| `stataMcp.sourcePathMappings` | 仅使用显式映射，见[路径映射指南](docs/source-path-mappings.md) |
| `STATA_WORKBENCH_HOME` | 绝对状态根目录，默认 `~/.stata-workbench`；VS Code 和 shell 使用相同值 |

CLI 还接受放在子命令**之前**的 `--state-root /absolute/path`，它选择已有注册表，不启动或移动会话。
本流程应清除旧的 `STATA_WORKBENCH_NEXT_HOME`。每个会话的运行时、检查点和临时文件位于
`<state-root>/runs/<sessionId>/`。不要复制 token，也不要手工改写会话归属记录。

## 排错

| 现象 | 操作 |
| --- | --- |
| `sessions` 中没有目标会话 | 核对已安装扩展、配置及状态根目录，在目标窗口手动 Start |
| `SESSION_LIMIT` | 已有两个引擎或清理尚未确认的占位；完成或关闭目标会话并核实清理，不要删除占位文件 |
| `RUNTIME_SOURCE_MISSING` 或依赖错误 | 准备匹配服务运行时；只装 VSIX 不够 |
| `DISK_RESERVE` | 准备运行时副本前恢复要求的可用空间 |
| 身份或 bundle 不匹配 | 使用匹配的已安装工具并检查原窗口，不绕过检查或改投目标 |
| `unknown-no-retry` / `EXECUTION_UNCONFIRMED_NO_RETRY` | 核对原 workflow 与回执，绝不盲目重交 |
| 提议发生未保存、版本或 SHA 冲突 | 保留人的缓冲区，待其保存后重新提议 |
| 要求恢复或 HTTP 423 | 停止依赖该状态的后续工作，检查原回执和窗口。KILL 须知情确认数据丢失风险，不绕过恢复检查 |
| 正在关闭或清理待确认 | 保留证据，检查精确归属的会话；清理不明不授权结束共用 Code 或其他 Stata 进程 |

## 已知限制

**0.2.0 普通窗口安装包尚未完成交付验收。** 待完成的检查包括精确安装包在 macOS/Windows 上的安装、
同配置双窗口隔离、实际 Codex/Claude 的发现与执行、真人 diff Accept/改稿/继续、Stop 与恢复/关闭。
离线测试、安装成功和历史 Next 实机结果都不能替代这些检查。
本指南不安装原生宿主的 Stop/diff/continue hook。远程扩展宿主、Linux 及其他未列出的系统变体未验证。

<details>
<summary>Next 历史限制与修复——仅适用于原构建</summary>

以下保留记录描述具名 Next 构建及其隔离启动器。“main”、五会话、启动选项和配置目录等内容均属历史，
不要把其中的安装或恢复步骤用于 0.2.0 普通窗口。

`main` 上已修复（`e9b22430`，PR #17），并已在 Windows 上用 `3765d82a`（11-03）实机确认，另有注明的除外：

- **Windows：开窗后的第一条命令曾经会把会话锁住（剩下的卡顿由下面的 warm-up 修复处理）。** `stataMcp.loadStataOnStartup: false` 时，Stata 要等第一条命令来了才加载。在 Windows 上，这第一条命令 3 次卡了 2 次，约 120 s 后返回 HTTP 504，会话被锁。启动器现在默认写 `true`，Stata 在开窗时就加载（Windows 11 上 57.7 s）。配置目录里显式写了 `false` 的，问题照样会出现（最后一次在 `3765d82a` 上核过）；启动器保留这个值，`open` 的回包会在 `backendLoad` 里说明。这样的会话被锁后点 **Stata: KILL** 解锁；要避免，就在 `open` 之前把 `profiles/<名字>/user-data/User/settings.json` 里的 `false` 删掉。到目前为止的测试里，macOS 没有这个问题。
- **被取消命令的迟到事件曾经记到别的运行上。** 在 Windows 上，一条取消已报「确认」的命令约 2 s 后照样执行了，它迟到的日志事件被交给了紧接着的那次运行（静默探针）。当时会话是锁住的，没人在错误状态上接着做；PR #15 之后，这种回包报 `EXEC_OUTCOME_UNKNOWN` 并带 `payloadMayHaveRun: true`（已在 Windows 上用 `e7e54848` 实机确认）。PR #17 让事件跟着自己的任务走：一次运行没等到回包就结束后，task id 不明的事件不再交给当前运行，而是暂存或丢弃。暂存区最多 256 条；如果 256 条全是 `log_path` 或 `task_done`，新来的 `task_done` 可能被丢。
- **看门狗取消曾经显示上一次失败的原因。** 在 agent 路径上，看门狗取消之后的状态沿用了之前一次 Terminal 失败的原因和时长。现在每次取消都写自己的 `stallReason` 和 `elapsedMs`，锁定原因写成例如 `EXEC_PRELOG_STALL (IDLE)`。`reasonCode` 本身对各种停顿仍都是 `EXEC_PRELOG_STALL`，因为客户端按它匹配。

`0.2.0-next.5` 之后在 `main` 上修复的，有离线测试和 CI。macOS 在 `main` `b0bc49d`（#27、#28、#22、#30、#31 之前）上做了实机复测，PR #30 另在它的最终 head `8739778` 上测过，PR #31 在最后一轮复审返工之前的 head 上测过。11-06 macOS 在 `d5b03df`（合并后的 bundle）上、Windows 在 `main` `d020b036` 上复测，结果写在各条里：

- **Windows：Stata 加载完后的第一条 Terminal 命令偶尔卡住（W-P1）。** 分段计时（PR #21）找到了卡在哪里。33 次里卡住的那 1 次，worker 里 Stata 自己的启动在 pre-flight 检查之后、到 `stata_setup.config` 结束之间用了 76.6 s（其余 32 次是 3.4–8.6 s）。命令一直在排队，没有丢：旧构建把这段等待算进了命令的 120 s 首条日志预算，在 Stata 就绪前 1.7 s 把它取消了。PR #18 起，命令先在这个预算之外等 Stata 加载完（默认最多 300 s）。带这段等待的构建 24 次 0 次卡住，其中 10 次是新建配置目录。这是统计上限（95% 置信度下卡住率低于约 12.5%），不能证明不会再卡。Stata 启动超过上限时，命令在派发前被拒绝（`PRE_RUN_BACKEND_WARMUP_TIMEOUT`），会话不会被锁。
- **不输出的长命令 60 s 后会被取消**（继承自稳定版）。看门狗现在还把本窗口自己的 Stata worker 用掉的 CPU 时间算作进展（PR #24，rc.7.84）。限制见下面的 CPU 信号一条；11-04 macOS 复测时，高负载下这样的命令仍被取消了，起因是 CPU 采样失败；PR #31 改了这一点（见下面）。
- **后端 connect 完成之前按 Stop 会锁住会话。** 现在只拒绝这条命令，不锁会话（PR #25，rc.7.83）。
- **同时跑的几个 `open` 会在 10 s 后互相超时。** 现在都在短锁里预留、锁外启动（PR #23）。
- **刚开窗时 agent 的提交会被拒**（`BLOCKED_NO_DISPATCH`），而 Terminal 命令会等。现在 agent 也等同一个 warm-up；拒绝结果带 `retryable` 和 `retryAfterMs`（PR #26，rc.7.86）。
- **warm-up 缓存可能信任一个已被换掉的 worker。** 现在缓存记下 worker 的 pid、启动时刻和 transport，用之前再核一次；核对失败或超时就当作没就绪。worker 在启动中挂掉时，Terminal 命令会把它重启一次（PR #20，rc.7.81）。
- **Stata 报错被报成结果不明。** 确认了的报错现在给 agent 返回 `STATA_ERROR_CONFIRMED` 和 Stata 的返回码（`stataRc`），Terminal 路径也报这个返回码，不再是 -1（PR #27，rc.7.85；PR #28 让 mcp-stata 发出返回码）。已在 macOS 的 `b82203d` 和 `d5b03df` 上实机验证，Windows 在 `d020b036` 上验证了 agent 路径，见下面的限制。
- **Windows 上的 Stata: KILL 曾经结束本机所有 Stata 图形界面进程和所有 mcp-stata 后端**，不只是本会话的；忙时的强制重置也一样。现在只结束本窗口已确认的后端进程树（PR #22，rc.7.82）。在 `d020b036` 上用两个会话实机跑过一次，确认了范围：只有被 KILL 的窗口的进程树结束，另一个窗口的 pid 不变、下一条命令照常执行。Windows 上那次 KILL 之后的恢复失败，见[平台实测结果](#平台实测结果)开头的说明和下面的限制。
- **人自己的 Run File 停不下来。** 它的进度通知「Running <文件> [Cancel]」盖住了 Terminal 的 Stop 按钮（`b0bc49d` 的 macOS 复测），通知的 **Cancel** 又没有接到任何操作，运行一直到 375 s 被看门狗取消，会话被锁。现在 Run File 或 Run Selection 通知里的 **Cancel** 调用和 Terminal 按钮同一个 Stop，只在打开通知的那次运行还在进行时生效（同一个执行生命周期、同一个 request id）（PR #30，rc.7.87）。Run File 已在 macOS 的 `8739778` 上实机核过；Run Selection 只有单元测试。旧通知的 Cancel 停不了之后的新运行、也停不了接手的 agent 运行，这一点只有离线测试；11-06 实机核对时造不出这种状态（旧通知总在新运行的通知出现前就关了）。
- **人停掉 agent 的运行，agent 拿到的是 `EXECUTION_UNCONFIRMED_NO_RETRY`。** 现在人在 VS Code 里用 Terminal 的 Stop 按钮或 **Stata: Cancel Current Request** 停掉 agent 的运行，agent 拿到 `STOPPED_NO_RETRY`（退出码 2，不重试）。Run File 和 Run Selection 的通知属于人自己的运行，停不了 agent 的运行。客户端只在这些条件都成立时才给它：这次 Stop 属于本次请求和本次运行，发生在这次提交之后，同一次 Stop 恢复了这次运行的运行前检查点（同一个 run id、`restored` 为 true、reset generation 相同），会话重新就绪（PR #30）。已在 macOS 的 `8739778` 上用 Terminal 的 Stop 按钮实机核过；**Stata: Cancel Current Request** 没在 agent 的运行上实机试过。`b0bc49d` 复测里 Stop 之后约 2 s 出现的 HTTP 423 `checkpoint restore in progress`，来自经测试端点 `/debug-terminal-input` 发的命令；agent 客户端要等会话就绪才发送。
- **人输入的报错命令卡片标题是普通的「Stata Output」。** 现在和 agent 一样显示「Stata Output (failed)」（PR #30）。
- **高负载下，一次 CPU 采样失败就可能让不输出的长命令被取消。** worker CPU 时间的采样失败、过期或超时，会重置看门狗的 CPU 基线，相隔约 12 s 的两次失败就可能空出 60 s 以上不算进展，而 worker 其实一直在算。11-04 macOS 复测时（负载均值约 200），`bootstrap _b, reps(400) nodots` 在 99 s 被取消。现在这样的采样不算进展，但保留基线，并按类型计数（`cpuErrorKinds`）。算进展仍要同一棵进程树的两次核实过的采样；进程树变了或有新日志，基线照样重置（PR #31，rc.7.88）。`/status.watchdogCpu` 给出正在运行的守卫，以及最近一次 agent 和 Terminal 守卫的这些计数。在 PR head `db105f28` 上，负载均值 61–76 时三条不输出的 `bootstrap` 都以 rc 0 完成，没有采样出错。触发取消的那种高负载没有复现，所以这项修复在那种负载下只有单元测试支撑。11-06 在 macOS（`d5b03df`）上一条 105 s 没有输出的 `bootstrap` 有 CPU 进展、没有采样出错地完成了，Windows（`d020b036`）上一条 192.8 s 没有日志输出的运行也一样。
- **macOS：命令运行中点 KILL 或强制重置，旧的 Stata worker 曾经会以父进程 pid 1 继续运行**，而 `/status` 和 `close` 都报告会话是干净的（`b82203d`，11-05）。KILL 和强制重置只结束 `mcp-stata` 服务进程，worker 只有在服务进程正常退出时才会跟着退出。现在强制重置先对后端进程树拍一次 `ps` 快照：根进程必须是登记的 pid，是本扩展宿主的直接子进程，启动不晚于登记后 5 s。结束服务进程之后，只对记下的、仍满足以下条件的后代先发 SIGTERM 再发 SIGKILL：启动时刻不变，工作目录在本会话的 workspace 或 `mcp-temp` 里，父进程是 pid 1 或记下的父进程。读不到或确认不了的情况，例如登记读不出、存活检查出错、有第二个活后端或一个活后端都没有，都在 `/status.orphanWorkers` 里列为 unresolved，不发信号，也不报干净（PR #31，rc.7.89）。`close` 只报告，除了 VS Code 窗口之外不发任何信号。结果里有 `leftoverProcesses`、`orphanWorkers` 和 `orphanCleanup`（`mode: "report-only"`、`signalled: []`、`clean`、`unresolved`、`holders`）。进程读取失败、超时、往 stderr 输出或只返回部分结果时，都算「不明」，不算「空」。只有没有 unresolved、而且对会话文件的最后一次扫描读成功并且没有占用者时，`clean` 才为 true。在最后一轮复审返工之前的 PR head `4a1ac2e` 上实机（macOS，11-05）：一条不输出的命令跑到 20 s 时点 KILL，旧 worker 和它的 resource tracker 被结束；同一工作目录里一个命令行含 `spawn_main` 的测试进程没有收到信号，一次 `close` 把它列为 unresolved。之后那轮返工（堵上可能被读成干净的几种情况）有离线测试和变异测试。合并后的代码在 `d5b03df` 上复测（11-06）：不输出的命令运行中点 KILL，旧 worker 和它的 resource tracker 再次被结束，测试进程没被动。那次复测发现了下面两条里的缺陷。
- **macOS：`close` 在真实 workspace 上列不出活着的 worker 或占用者**（11-06 复测）。只要文件夹里有一个没有进程打开的文件，`lsof +d <workspace>` 就以退出码 1 结束，同时照样输出它找到的进程。#31 把这种情况算作「不明」，所以在任何真实 workspace 上 `close` 都报 `identity-unreadable` 和 `holders: unknown`。现在目录扫描在退出码为 0 或 1 且 stderr 为空时读取这些行；其他退出码、有 stderr 输出（比如打不开的文件夹）或超时仍算「不明」（PR #32）。只在 macOS lsof 4.91 上实机核过：一个占着 workspace 的测试进程被列为 unresolved（`holders: present:1`、`clean: false`、什么信号都没发）。`close` 仍然只报告、尽力而为，见下面的限制。
- **macOS：有后端进程被停住时，强制重置会带走 VS Code 的扩展宿主**（11-06 复测，4 次都出现）。本窗口的 Stata worker 被 SIGSTOP 停住时，看门狗取消升级为强制重置；服务进程结束约 1 s 后，扩展宿主退出（code 0），只剩 VS Code 主进程。原因有实测强力支持，但没有直接观测到（没有抓到 SIGHUP）。在所测的启动方式下（macOS，由 `tools/stata_session.py` 用隔离配置目录启动的窗口），窗口的所有进程，包括 mcp-stata 服务进程、它的 resource tracker 和 worker，都在 VS Code 主进程的进程组里。服务进程退出后，tracker 和 worker 被过继给 launchd，仍留在这个组里。这样的成员退出时如果组里还有别的成员被停住，内核就把这个组当作孤儿进程组，向整个组发 SIGHUP 和 SIGCONT：扩展宿主和各个辅助进程结束，VS Code 主进程活下来。rc.7.89 的清理在 worker 被停住时结束了已过继的 tracker，触发了这一点。现在清理在每次发 SIGTERM 或 SIGKILL 之前先读宿主的进程组。被停住、且与记下的身份（pid 和启动时刻）一致的成员先收到 SIGCONT，然后再读一遍进程组。有不是我们的成员被停住（`host-group-stopped`）或读不到进程组（`host-group-unknown`）时不发信号，这一行保持 unresolved。每次读完进程组之后、每次发 SIGCONT 之前都检查截止时间、取消和更新的重置（PR #33，rc.7.89-v4）。在 PR #33 的第一个 head `3c8e4f3` 上实机 2/2：宿主活了下来，**Stata: KILL** 解锁了会话，下一条命令 rc 0，`close` 返回 `CLOSED`；其中一次有一行 `host-group-unknown`，原因没查到。新加的停止检查只有离线测试和变异测试。
- **Windows：KILL 成功之后，窗口一直拒绝运行**（11-06 复测）。命令在它刚结束掉的那个后端的连接上跑恢复 smoke，smoke 以 `transport-failed` 失败，下一条命令得到 HTTP 423 `panic-kill-command-needs-smoke`；测试随后关掉了窗口（没有试第二次 KILL 或 `POST /recovery-smoke`）。现在范围内的 KILL 成功后会先做一次强制重置：沿用这次 KILL 记下的结果，打开新连接，会话保持「需要 smoke」；smoke 随后在新连接上跑（PR #34，rc.7.90）。fail-closed 路径和部分结束的情况不变。在 `main` `80e01c8` 上实机（11-07）跑过一次，两个会话：被 KILL 的窗口自己恢复，下一条命令 rc 0；另一个窗口不受影响。

当前 `main` 上还没解决的问题：

- **Stata 还在加载时交的命令。** `trueReady` 不等后台加载。Terminal 命令和 agent 的提交都会先等 Stata worker 进入 running；等过 2 s，Terminal 显示「Waiting for Stata to finish loading…」，点 Terminal 的 Stop 按钮或用 `POST /soft-stop` 都可以取消等待。等满 300 s 或 warm-up 失败时，命令在发出之前就被拒绝（`PRE_RUN_BACKEND_WARMUP_TIMEOUT` 或 `PRE_RUN_BACKEND_WARMUP_FAILED`，`payloadDispatched=false`）。只有不提供 `list_sessions` 的旧版 mcp-stata 才不经这项检查直接放行（这是兼容做法，不能证明 Stata 已就绪）。有 `list_sessions` 但连续失败或超时时，warm-up 以 `FAILED` 结束，命令被拒绝；warm-up 刚结束时 worker 变了或确认不了，命令会再等一次，仍不行就拒绝。11-04 在 macOS 上实机确认了等待提示、等待中 Stop（经 `/soft-stop`）、超时和失败拒绝；Windows 上确认了除失败拒绝以外的几项，等待提示只在 Output 日志里核过；11-06 在 Windows（`d020b036`）上，失败拒绝和真实 Terminal 面板里的等待提示也都看到了。11-05 在 macOS（`b0bc49d`）上往 Terminal 面板里输入命令，等待期间 Stop 按钮是可用的；点它之后命令以 `PRE_RUN_BACKEND_WARMUP_CANCELLED` 被拒绝，什么都没发出，下一条命令 rc 0。之前说「等待期间 Stop 按钮被禁用」，来自一个测试端点（`/debug-terminal-input`）：它发命令时不经过面板的 Run 处理，面板就一直没显示命令在运行。这不是产品缺陷。
- **Windows KILL 的范围只有两次实机运行支持。** 在 `d020b036` 和 `80e01c8` 上各用两个会话跑过一次：对窗口 A 点 KILL 只结束了 A 的后端进程树，窗口 B 的 pid 不变，下一条命令 rc 0。两次运行不构成统计上限。根进程按登记时刻（1 s 以内）认定，不是按记下的创建时间；身份比到毫秒；进程列表不是原子快照；结束之后只再扫一遍直接子进程。清理失败或读不到进程身份时，会话保持未就绪，`/recovery-smoke` 返回 HTTP 423 `unresolved-cleanup`。
- **Windows：后端完全冻住时按 Stop 会锁住会话。** 一个会话的后端进程全部被挂起时，`/soft-stop` 用了 58 s，返回 500（`RECOVERY_FAILED`：静默探针 5 s 超时），并强制重置了本会话自己的进程树。之后会话一直以 HTTP 423（`soft-stop-needs-smoke`）拒绝命令，直到关掉窗口。日志给出的办法是 **Stata: KILL** 或 `POST /force-reset`；在冻住的会话上两者都没试。PR #34 之后，KILL 成功时会在 smoke 之前重置连接，但这种 Stop 之后再 KILL 还没有实机试过。慢但还活着的后端没测。
- **Windows：在面板里输入、warm-up 期间被拒的命令，`/status.lastTerminalGuardFailure` 为空。** 拒绝只显示在面板和日志里。
- **macOS 的 KILL 和强制重置只按 pid 认后端**（PR #22 只改了 Windows）。 清理时，登记的 pid 的命令行里含 `mcp-stata` 就结束它，不核对进程启动时刻和父进程。如果这个 pid 正好被别的会话的 `mcp-stata` 复用，有可能被误结束。
- **macOS 孤儿 worker 清理的限制。** 信号发给裸 pid：一个进程在最后一次核对之后退出、它的 pid 在发信号前被复用，这种情况排除不了；启动时刻也只精确到 1 s。根进程规则是单边的：本扩展宿主的另一个子进程如果在登记后 5 s 内拿到登记的 pid，排除不了。`close` 的收集和报告两段各有 8 s 时限，管的是清理的进程读取，不是整个调用：高负载下 `close` 仍可能在列实例时因 `ps` 超时抛错，而不是返回结论。收集时间用完的行一直记为 unresolved，即使那个进程之后正常退出了。`close` 已实机列出过一个占着 workspace 的测试进程（11-06），还没有列出过比窗口活得更久的真实 Stata worker：11-05 的测试里 worker 总是随 VS Code 退出而结束；11-06 一个用 SIGSTOP 停住的 worker 有一次比窗口活得更久，但当时那个构建的 `close` 列不出它（PR #32 已修），其余几次它都在退出过程中结束了。`close` 只报告、尽力而为：它只扫 workspace 文件夹和直接放在里面的文件（`lsof +d` 不递归），进程读取不是原子的，而且只在 macOS lsof 4.91 上核过，所以 `holders: none` 和 `clean: true` 的意思是在这个范围里没看到。自己动手结束进程之前，先用 `ps -o pid,ppid,lstart,command -p <pid>` 核对 unresolved 的那一行。Windows 不变（那里 PR #22 结束本窗口整棵后端进程树），这种情况没在 Windows 上测过。
- **macOS：窗口里另有进程被停住时，KILL 或清理不受支持。** PR #33 只保证强制重置不会在我们记下的进程被停住时结束组里的成员。如果窗口里的某个进程是被外部停住的（SIGSTOP、调试器），之后的 **Stata: KILL** 或清理仍可能以同样方式带走扩展宿主（实机见过）。窗口里一个被停住、但不是记下身份的进程会挡住清理（各行 unresolved），它不会被恢复。最后一次读进程组到发信号之间 pid 被复用、或进程又被停住，这些情况排除不了。
- **worker CPU 信号是一种近似。** CPU 在跑不等于在做有用的事：一直空转、不输出的运行，最多能占着会话到日志连续 30 分钟没动静为止。核实不了进程树时（采样期间有 pid 退出、超过 4 层或 16 个进程、父进程对不上），这次采样不算进展，照 60 s 日志规则判断。同一秒内的 pid 复用超出它所核对的启动时刻的精度。11-04 在 macOS 上复测 `main`（`b0bc49d`）：一条 57 s 不输出的运行以 rc 0 完成，被冻结的 worker 仍被取消；高负载下一条更长的不输出运行被取消了（见下一条）。
- **最高负载下不输出的长命令，PR #31 之后还没有实机复测。** 11-04 的那次取消（负载均值约 200，99 s，`cpuErrors=2`）来自 CPU 采样失败重置了基线，PR #31 改了这一点（见上面已修复的一条）。11-06 不输出的运行在 macOS（105 s 没有输出）和 Windows（192.8 s）上都有 CPU 进展地完成了，但那种负载和那些采样失败没有复现，所以针对它们的修复只有单元测试支撑。看门狗取消之后会话仍会锁住（HTTP 423 `guard-cancel-needs-smoke`），直到点 **Stata: KILL**；这个锁是有意的，因为取消之后 Stata 里的状态是未知的。
- **人跑 Run File 或 Run Selection 时的进度通知会盖住 Terminal 的 Stop 按钮。** 通知里的 **Cancel** 现在能停下运行（见上面已修复的一条）。点通知的正文没有作用；Run Selection 上的 Cancel 只有单元测试；两者都没在 Windows 上核过。旧通知的 Cancel 停不了更新的运行，这一点只有离线测试：11-06 实机试了三次，旧通知总在新运行的通知出现前 4.7–10 s 就关了。
- **经 `POST /soft-stop` 或看门狗的 Stop，agent 拿到的是 `EXECUTION_UNCONFIRMED_NO_RETRY`**，不是 `STOPPED_NO_RETRY`；回执在 `stopReportedBy` 里写明来源。重新提交之前，先看 `/status` 的 `resetGeneration` 和回执。`STOPPED_NO_RETRY` 已在 Windows 的 `d020b036` 上（11-06）用 Terminal 的 Stop 按钮核过。
- **Stata 报错的返回码按保守条件确认；Windows 上只实机测了 agent 路径。** 只有同时满足这些条件才算确认：这次运行没被取消（Stop、watchdog、Break、rc 1），日志是这次运行自己的，最后一行 `r(n)` 后面只有回显的命令，完成 marker 没有打印出来，返回码是正整数且等于 mcp-stata 给的 rc。mcp-stata 只有打了运行时补丁（PR #28）才在 `task_done` 里带这个 rc，取自本次运行已经拿到的响应；没打补丁的运行时不带 rc，报错一律确认不了。其他情况 Terminal 路径仍是 rc -1，agent 仍拿到 `EXECUTION_UNCONFIRMED_NO_RETRY`；报错文字里提到 cancel、timeout 或 stall 的也不确认。macOS 构建 `b82203d`（11-05）：agent 交的 `display nosuchvar` 返回 `STATA_ERROR_CONFIRMED`、`stataRc` 111，下一条命令 rc 0；人输入同一条报错命令，运行以 rc 111 结束，下一条命令 rc 0；会话一直可用。这个构建不是现在的 `main`；同样的检查在 `d5b03df` 上（11-06）也通过了。Windows（`d020b036`，11-06）：agent 交的 `display nosuchvar` 返回 `STATA_ERROR_CONFIRMED`、`stataRc` 111，下一条命令 rc 0；Stata 日志里有 `r(111);`，扩展日志里没有报错文字。人在 Windows 上输入的报错命令没测。离线跨模块测试里的 `task_done` 结果是手工构造的，界面部分是桩，所以它不是 MCP 传输测试，也不是端到端测试。
- **通用的日志解析器只认普通写法 `r(n);`**，不认 mcp-stata 1.26.1 写的 SMCL 写法 `{search r(111), local:r(111);}`，只有新的报错检查两种都认。报错没被确认时，release 时推断的 rc、Run File 的收尾和 watchdog 的报错检查在这类日志里仍然看不到 rc。
- **Terminal 里能看到包装行。** RESULT 页会显示每条命令前后加的行，比如 `display as text "___CODEX_RUN_DONE_…___"`、第二个 `r(111);` 和 `scalar _wb_rc_… = _rc`；agent 卡片的命令行里还能看到客户端的核验 marker。它们来自扩展和 mcp-stata 运行时对命令的包装。完成检查和一次运行的日志证据都依赖这层包装，所以暂时没有隐藏。
- **重开的会话可能换端口。** 刚 `close` 完，旧端口可能还处于 TIME_WAIT，启动器就换下一个空闲端口。工具按会话名找会话。
- **Windows 派发开销。** 在 Windows 上，每次 agent 提交比 Stata 本身的工作多花约 15 s（派发前检查和回执核验）；一条短命令从头到尾要 17.4 s。20 轮 8 s 命令里，每次提交的固定开销是 12–18 s。
- **启动服务可能要等 PyPI。** 扩展在启动 Stata 服务之前，会先去 PyPI 查一次 `mcp-stata` 的版本。在这个请求会超时的机器上，超时时间会算进第一次启动。
- **内存。** 每个会话都是完整的一份 VS Code 加 Stata。macOS 上 5 个会话 RSS 合计 3852–4000 MB（每个 718–850 MB）。在 16.8 GB 内存的 Windows 机器上，两个空闲会话的工作集分别是 1.93 GB 和 2.16 GB，有负载时每个 2.00–2.39 GB。这种配置的机器开第三个会话前，先看可用内存。
- **工作区信任。** 新工作区要点一次 **Trust**，扩展才会启动。
- **agent 宿主。** Codex 没有针对 `.do` 文件的按文件 deny 规则，见[agent 改 Stata 文件要经人审阅](#agent-改-stata-文件要经人审阅)。
- **继承自稳定版的：** 多行选区里顶层的 `exit` 会结束整个选区，并被报成失败；Data Browser 的 frame 名只在打开浏览器时更新；只用 `graph use` 不会在 Terminal 里生成图卡片；不保证显示的源码和实际执行的字节完全一致。
- 维护的是 `dist/extension.js` 这个 bundle。另有一套参考源码构建，但它和 bundle 的功能是否一致没有确认。

</details>

## 平台实测结果

**仅为历史证据。** 以下是原 Next 结果，不是 0.2.0 候选版、普通窗口或实际真人/agent 宿主的验收通过记录。
原构建哈希与限制按原样保留，不重新标注归属。

<details>
<summary>原 Next 平台记录</summary>

所有实机测试都用隔离的 Next 配置目录、合成的 `.do` 文件和 `17601`–`17620` 端口，没有用到研究数据。
界面操作（Stop、Trust、KILL）通过 VS Code DevTools 协议驱动，不是真人按键。日期为 2026 年、台北时间。
构建指 `main` 的提交：`e7e54848`、`579b0fe9` 和 `171138b6` 都是 `0.2.0-next.5`，`8d63cb45` 是 `0.2.0-next.4`。

11-04 的各行来自两类构建。`aba81779` 是 `v0.2.0-next.5` 发布版。`a1a2832b`（PR #21）、`40abcbea`（PR #20）
和 `2ec968a`（PR #24）是 PR 的 head，在复审返工和合并之前测的。之后 macOS 在 `main` `b0bc49d` 上做了实机复测，
Stata 报错返回码和 KILL 后遗留的 worker 另在 `b82203d` 上测过。
PR #30 在它的最终 head `8739778` 上做了实机检查，这个 head 的文件树和合并提交 `e0b4e11` 相同。PR #31 在最后一轮复审返工之前，于 macOS 的 head `db105f28` 和 `4a1ac2e` 上做过实机检查，见[已知限制](#已知限制)。

<!-- FMAC-RESULT -->
11-06 对合并后的运行时做了实机复测：macOS 用 `d5b03df`（PR #31 的合并候选；扩展 bundle 和清理核心与 `main` `d020b036` 相同，只有 Python 的 `close` 工具不同），Windows 用 `main` `d020b036`（16 项里 15 项通过）。这几轮发现了由 PR #32 和 PR #33 修复的两个 macOS 缺陷，以及下面的 Windows KILL 恢复缺陷。PR #33 的最后一个提交 `32ff282`（恢复步骤前后的停止检查）只有离线测试。在发布提交上做过的检查列在它的 GitHub 发布说明里。
<!-- /FMAC-RESULT -->

<!-- KW-RESULT -->
这几轮发现的 Windows KILL 恢复缺陷已由 PR #34（rc.7.90）修复。11-07 在 `main` `80e01c8`（#34 的合并提交）上对 Windows 做了实机复测：两个活会话中对一个点 **Stata: KILL**，只结束了这个窗口的后端进程树，这个窗口自己恢复（恢复 smoke 通过，下一条命令 rc 0），另一个窗口的进程不变，下一条命令 rc 0。
<!-- /KW-RESULT -->

### macOS（Apple Silicon，macOS 26.5，StataNow，VS Code 1.139.1）

| 检查 | 构建、日期 | 结果 |
| --- | --- | --- |
| 人和 agent 共用一个会话（global、变量、估计结果、图；Terminal 卡片显示 agent 名和回执里的 runId） | `8d63cb45`，11-01 | 通过 |
| 同时运行 2、3、5 个会话 | `8d63cb45`，11-01 | 通过。5 个会话重叠 28.57 s，各自读回自己的 owner、N 和系数；第 6 个 `open` 返回 `SESSION_LIMIT` |
| 注册表与身份校验的拒绝（陈旧记录、PID 被复用、token 错、generation 不符、多个活会话不带 `--session`） | `8d63cb45`，11-01 | 通过，7/7 被拒且没有执行 |
| 两个 agent 同时往两个会话提交（30 s 命令，间隔 0.008 s 发出） | `579b0fe9`，11-02 | 通过。两边都是 HTTP 200，分别用时 34.41 s 和 34.26 s |
| 一个会话跑 60 s，另一个会话交短命令 | `579b0fe9`，11-02 | 通过。长命令还在跑时，短命令 4.50 s 就返回了 |
| 两个会话都在忙时只 Stop 其中一个 | `579b0fe9`，11-02 | 通过。被停的会话恢复就绪；另一个照常跑完，重置代数不变 |
| 两个活会话时不带 `--session` | `579b0fe9`，11-02 | 通过。`MULTIPLE_SESSIONS`，什么都没执行 |
| 两个会话关掉一个 | `579b0fe9`，11-02 | 通过。它的注册表记录已删除；另一个会话照常能跑代码 |
| 人的长命令在 Terminal 里按 Stop，两次 | `579b0fe9`，11-02 | 通过。两次都是第一次点击就停，Stata 进程不变，数据保留 |
| 对 agent 运行按 Stop | `579b0fe9`，11-02 | 通过。没有强制重置，运行前状态已恢复（`RECOVERED_FULL`） |
| 运行前检查点被删掉后按 Stop | `579b0fe9`，11-02 | 通过。会话锁住（`trueReady: false`，下一次运行 423，状态栏 STALE） |
| **Stata: KILL** 解锁 | `579b0fe9`，11-02 | 通过。确认一次，恢复 smoke rc 0，下一次运行成功 |
| 开窗后第一条命令，`loadStataOnStartup` 为 `false`（5 次）和 `true`（2 次） | `aba81779`，11-04 | 通过，7/7 HTTP 200、rc 0，没有在首条日志前卡住。命令先等 Stata 加载完（`false` 11–14 s，`true` 约 7 s，第一次冷启动 61 s），Output 日志先写「Waiting for Stata to finish loading…」，再写「finished loading after N s」 |
| Stata 还在加载时交的命令：按 Stop、超时、worker 失败 | `aba81779`，11-04 | 通过。等待中按 Stop：HTTP 409 `PRE_RUN_BACKEND_WARMUP_CANCELLED`，什么都没发出，下一条 rc 0。worker 被冻结：336.5 s 后 HTTP 504 `PRE_RUN_BACKEND_WARMUP_TIMEOUT`，会话没锁。随后结束该 worker：HTTP 500 `PRE_RUN_BACKEND_WARMUP_FAILED`；下一条命令等了 37 s 重新加载，返回 rc 0 |
| 后端 connect 完成之前按 Stop | `aba81779`，11-04 | 失败。什么都没发出，但软 Stop 35.6 s 后返回 500，会话被锁（`soft-stop-did-not-restore-checkpoint`）。在这个构建上失败。rc.7.83（PR #25）已修；在 `main` `b0bc49d` 上实机通过（connect 前按 Stop，命令被拒、会话没锁，下一条命令 rc 0） |
| 命令运行时点 Terminal 的 Stop 按钮 | `aba81779`，11-04 | 第一轮 0/2：测试驱动点的位置被 Welcome 页的透明遮罩盖住，点击没有到达 Terminal。关掉 Welcome 之后，鼠标点击、在 Terminal 视图内点击、**Stata: Cancel Current Request** 各一次都停下了运行，会话没锁 |
| 人和 agent 轮流跑；agent 运行中人插话 | `aba81779`，11-04 | 通过。人的提交得到 HTTP 409 `bridge busy`，写明正在运行的 agent；之后双方读到同一个 owner、N 和系数 |
| 两个活会话时点 **Stata: KILL** | `aba81779`，11-04 | 通过。只有被锁会话的 3 个进程被换掉；另一个会话正在跑的 40 s 命令照常 rc 0 完成 |
| 5 个活会话，3 个同时提交 | `aba81779`，11-04 | 部分通过。第 6 个 `open` 得到 `SESSION_LIMIT`。3 个同时提交里 2 个通过；一个在窗口报就绪约 20 s 后交的 agent 提交，因为后端还没起来，在派发前被拒（`BLOCKED_NO_DISPATCH`）。在这个构建上失败。rc.7.86（PR #26）已修；在 `main` `b0bc49d` 上实机通过（开窗后立即交的 agent 命令 rc 0，与 `lastCold.runId` 一致） |
| 高负载下（load average 120–140）不输出的长命令 | `aba81779`，11-04 | 失败。一条 `bootstrap … dots(50)` 60 s 没有新日志，63 s 时被当作 `EXEC_PRELOG_STALL (IDLE)` 取消，会话被锁。rc.7.84（PR #24）加了 worker CPU 信号 |
| worker CPU 信号：空闲噪声和真卡死 | `2ec968a`，11-04 | 通过。空闲 worker 的 CPU 时间每 12 s 增长 10 ms（阈值 200 ms）。用 SIGSTOP 冻结的 worker 照样被取消，冻结后 69.7 s；KILL 之后下一条命令 rc 0。不输出的长命令那一项在首条日志预算内就结束了，所以「60 s 空闲且有 CPU 进展」那条路径还没有实机测到 |
| agent 交的命令 Stata 报错（`display nosuchvar`） | `b82203d`，11-05 | 通过。`STATA_ERROR_CONFIRMED`，`stataRc` 111，各项报错检查都为真；Terminal 卡片显示 RC 111。下一条 agent 命令 rc 0，会话保持就绪 |
| 人在 Terminal 里输入的命令 Stata 报错 | `b82203d`，11-05 | 通过。运行以失败结束、rc 111，面板显示 `RC 111` 和 `r(111);`。下一条输入的命令 rc 0，之后 agent 命令 rc 0 |
| 人跑 Run File 时点通知里的 **Cancel**（「Running long_dots.do [Cancel]」） | `8739778`（PR #30），11-05 | 通过。这次点击经和 Terminal 按钮同一个 Stop 停下了运行；5 s 后会话空闲，运行前的状态已恢复，之后在面板里输入的命令 rc 0 |
| 人用 Terminal Stop 停 agent 的运行 | `8739778`（PR #30），11-05 | 通过。agent 拿到 `STOPPED_NO_RETRY`，`stoppedBy` 为 person，各项 stop 检查都为真；只发了一次请求，没有重试。下一条 agent 命令通过 |
| 打包、`verify_release` 和装好的 bundle | `d5b03df`，11-06 | 通过。VSIX 里的 bundle 和装好的 bundle 都等于固定的 SHA-256；`verify_release --vsix` 116/116；运行时清单的 115 个文件与装好的副本一致 |
| 开窗后第一条命令，`true` 和 `false` 各两次；等待中按 Stop | `d5b03df`，11-06 | 通过，4/4，面板和日志里都有等待提示。等待中 Stop（经 `/soft-stop`）以 `PRE_RUN_BACKEND_WARMUP_CANCELLED` 被拒，什么都没发出，下一条命令 rc 0 |
| Run File 通知里的 **Cancel**；人用 Terminal Stop 停 agent 的运行 | `d5b03df`，11-06 | 通过。Cancel 停下了运行，运行前状态已恢复，之后输入的命令 rc 0。agent 拿到 `STOPPED_NO_RETRY`（一次请求、没有重试，8 项 stop 检查都为真） |
| 新运行进行中点旧通知的 **Cancel** | `d5b03df`，11-06 | 没做到。3 次尝试里，旧通知都在新运行的通知出现前 4.7–10 s 关掉了；新运行每次都 rc 0。只有离线测试 |
| agent 和人各交一条报错命令 | `d5b03df`，11-06 | 通过。agent：`STATA_ERROR_CONFIRMED`、`stataRc` 111，下一条 agent 命令 rc 0。人：rc 111，下一条输入的命令 rc 0 |
| 四个活会话：轮流、报错命令、Stop、对其中一个点 KILL | `d5b03df`，11-06 | 通过。KILL 只换掉了那个会话自己的三个进程；另一个会话 40 s 的循环以 rc 0 跑完。人跑 Run File 时用鼠标点面板的 Stop，仍点在通知上；通知里的 Cancel 能停下运行 |
| 不输出的命令运行中点 KILL（孤儿 worker） | `d5b03df`，11-06 | 通过。旧 worker 和它的 resource tracker 被结束；同一文件夹里一个命令行像 worker 的测试进程 pid 和启动时刻都没变 |
| 不输出的 `bootstrap … reps(400) nodots`；`/status.watchdogCpu` | `d5b03df`，11-06 | 通过。105 s 没有输出，108 s 以 rc 0 完成，有 CPU 进展（8 次采样里 7 次，0 次出错）；22 次轮询都有 `watchdogCpu` |
| 本窗口的 worker 被 SIGSTOP 停住时的强制重置 | `d5b03df`、`d020b036`，11-06 | 失败，4/4。强制重置结束服务进程约 1 s 后，扩展宿主退出（code 0），只剩 VS Code 主进程，`close` 返回 `CLOSE_PENDING`。`e0b4e11`（#31 之前）上没有出现。由 PR #33 修复 |
| 在 PR #33 的第一个 head 上做同样的对照 | `3c8e4f3`，11-06 | 通过，2/2。发任何终止信号之前 worker 先被恢复，扩展宿主活了下来；**Stata: KILL** 解锁了会话，下一条命令 rc 0，`close` 返回 `CLOSED`。其中一次有一行 `host-group-unknown`（什么都没发；原因没查到） |
| 还有进程占着 workspace 时的 `close` | `d5b03df`、`d020b036`，11-06 | `d5b03df` 上失败：每次 `lsof +d` 都以退出码 1 带行返回，`close` 报 `identity-unreadable` 和 `holders: unknown`。用 #32 的 `close` 工具（`main` `d020b036`）通过：一个占着 workspace 的活测试进程被列为 unresolved（`holders: present:1`、`clean: false`、什么信号都没发）。比窗口活得更久的真实 Stata worker 没有造出来 |

### Windows（Windows 11 x64，Stata 18 MP，VS Code 1.144.0）

| 检查 | 构建、日期 | 结果 |
| --- | --- | --- |
| 新配置目录关闭 VS Code 和扩展的自动更新 | `171138b6`，11-02 | 通过 |
| agent 改稿审阅：接受、拒绝、审阅期间被改 | `171138b6`，11-02 | 通过 |
| 拒绝：PID 被复用、token 错、端口被占、陈旧记录 | `171138b6`，11-02 | 通过，什么都没发 |
| 双会话：两个 agent 同时提交、一边忙一边提交、Stop 其中一个、互不串、`MULTIPLE_SESSIONS` | `579b0fe9`，11-02 | 通过。两次运行重叠 40.5 s；读回分别是 `owner=w3a N=111` 和 `owner=w3b N=222` |
| 双会话 20 轮同时提交（40 次运行，其中 5 次中途 Stop） | `e7e54848`，11-03 | 通过，20/20。没被 Stop 的 35 次全部通过，日志没有一行串到另一个会话；被 Stop 的 5 次都恢复了、没有强制重置，另一个会话的重置代数不变（5/5）。20 轮里 Stata pid 都没变 |
| 人的长命令在 Terminal 里按 Stop，五次 | `e7e54848`，11-03 | 通过，5/5。第一次点击就停，Stata 进程不变，Stop 之前的数据保留 |
| 运行前检查点被改名后按 Stop | `e7e54848`，11-03 | 通过。提示写明没有恢复运行前状态、会话已锁、要点 **Stata: KILL**；状态 fenced，下一次运行 423。`579b0fe9` 上同一场景的提示错说检查点已恢复 |
| 人的长命令在 Terminal 里按 Stop，两次 | `579b0fe9`，11-02 | 通过，2/2：第一次点击就停，Stata 进程不变，数据保留 |
| 从 Terminal 停掉 agent 运行 | `579b0fe9`，11-02 | 通过。运行前检查点已恢复（`restored=true`），读回 N=77 |
| 运行前检查点被移走后按 Stop | `579b0fe9`，11-02 | 通过。会话锁住（`snapshot-expected-not-restored`） |
| 看门狗取消一条静默的 agent 命令 | `579b0fe9`，11-02 | 部分通过。运行前检查点已恢复，但取消升级成了强制重置，状态里报的是上一次失败的原因 |
| 看门狗取消一条静默的 Terminal 命令 | `e7e54848`，11-03 | 通过。静默探针读到了自己的 marker，没有强制重置；锁定原因是这次取消自己的（`elapsedMs 63187`、`stallReason IDLE`） |
| 开窗后的第一条命令，`loadStataOnStartup=false` | `579b0fe9`，11-02；`e7e54848`，11-03 | 时好时坏：3 次卡了 2 次（约 120 s 后 HTTP 504，会话锁住）；另一次 42.2 s 返回 rc 0。`e7e54848` 上的 504 报 `EXEC_OUTCOME_UNKNOWN`、`payloadMayHaveRun: true` |
| 开窗后的第一条命令，`loadStataOnStartup=true` | `579b0fe9`，11-02 | 通过。开窗时 Stata 在后台加载，用了 57.7 s；之后第一条命令 6.1 s 完成，rc 0 |
| 默认 `loadStataOnStartup`（配置里没有这个键），开窗后第一条 agent 命令 | `3765d82a`，11-03 | 通过，3/3。启动器写入 `true`；`open` 之后 106.6–107.7 s Stata 就绪；第一条 agent 命令 23.1–25.2 s 返回 rc 0。`open` 之前写好的 `false` 被保留 |
| agent 路径和 Terminal 路径上的看门狗取消 | `3765d82a`，11-03 | 通过。每次取消都在 `/status.lastGuardFailure` 记下自己的 `runId` 和 `elapsedMs`（63 615 ms 和 63 159 ms）；锁定原因 `EXEC_PRELOG_STALL (IDLE)`。只出现了 `IDLE` 这一种停顿 |
| 被取消的冷启动命令的迟到事件（`loadStataOnStartup=false`） | `3765d82a`，11-03 | 通过。命令 167.1 s 后返回 HTTP 504；它迟到的 `log_path` 事件以 `not this client's run` 被丢弃，没有交给下一次运行 |
| 这类取消之后的普通命令；重新开窗后的第一条 Terminal 命令 | `3765d82a`，11-03 | 部分通过。解锁后同一后端：5/5 rc 0，每条约 3.1 s，日志里没有别人的行。默认 `true` 重新开窗：0/2。`connect` 完成（54.2 s）后立刻发的第一条 Terminal 命令在首条日志前卡住，163.9 s 后返回 HTTP 504；会话被锁，第二条得 423 |
| 两个会话，8 轮同时提交 agent 命令、其中 2 轮按 Stop；Terminal Stop 3 次 | `3765d82a`，11-03 | 通过。没被停的 14/14 全部通过；被停的 2 次都恢复了，没有强制重置；日志没有串到另一个会话；每轮 21.4–24.8 s。Terminal Stop 3/3 第一次点击就停 |
| `close` 清理残留的临时注册表文件 | `171138b6`，11-02；`e7e54848`，11-03 | `171138b6` 上部分通过（漏了一个文件）。`e7e54848` 上通过：写入进程已退出的文件被删，注册表为空。「进程已退出却报错误码 5」这种情况没出现（三个都报 87），那一支只有单元测试 |
| 跳过恢复 smoke 时的 KILL 提示；迟到事件后探针读自己的日志 | `e7e54848`，11-03 | 部分通过。前者在 Windows 上走不到（那里 KILL 一定会跑 smoke）；后者需要的迟到事件在两次懒加载里都没复现。两支都只有单元测试 |
| 新开窗、`connect` 刚完成就发的第一条 Terminal 命令 | `e5d2cda7`，11-04 | 通过，3/3。HTTP 200、rc 0，3.05–3.12 s 返回；第二条也通过。派发前扩展先查了 worker 状态（`list_sessions` 4–6 ms；worker 已在 running，所以没有出现等待提示）。同一检查在 `3765d82a` 上也 2/2 通过，所以这次复测不能说明之前那次卡住已经消除 |
| 开窗后第一条 agent 命令；4 次 agent 运行、最后一次软 Stop；Terminal Stop | `e5d2cda7`，11-04 | 通过。第一条 agent 命令 11.5 s 返回 rc 0。第 1–3 次 14.4–15.7 s 通过；被停的那次恢复了检查点（`restored=true`，没有强制重置），Stop 之前的数据保留。Terminal Stop 第一次点击就停，Stata 进程不变 |
| 开窗后第一条 Terminal 命令，带分段计时（`loadStataOnStartup` 为 `true` 和 `false`，新建和复用的配置目录） | `a1a2832b`，11-04 | 通过，24/24 HTTP 200、rc 0，其中 10 次用的是新建配置目录。每条第一条命令都先等 Stata 加载 16–60 s，之后运行、log path 和首行输出在 0.6 s 内跟上。带同样计时行的旧构建 `3765d82a` 17 次里卡了 1 次（约 120 s 后 HTTP 504）；见[已知限制](#已知限制) |
| 4 条 8 s 命令，第 2 条软 Stop；点一次 Terminal 的 Stop 按钮 | `a1a2832b`，11-04 | 通过。Stop 1.65 s 返回，检查点已恢复，没有强制重置；另外 3 轮的开始和结束行都写进了日志；Stata 进程不变。Terminal Stop 第一次点击就停。面板刚拿到焦点时的第一次 Run 点击没有反应，和之前的 Windows 测试一样 |
| Stata 还在加载时交的命令（worker 被挂起）：按 Stop、超时、重启 | `40abcbea`，11-04 | 通过。等待中按 Stop：以 `PRE_RUN_BACKEND_WARMUP_CANCELLED` 被拒，Stata 日志里什么都没有。超时：300.1 s 后 HTTP 504 `PRE_RUN_BACKEND_WARMUP_TIMEOUT`，什么都没发出。恢复后下一条命令 46.1 s 返回 rc 0；它的 worker 在启动中失败过，被重启一次、43 s 加载完，命令只执行了一次。没有出现用户可见的 `PRE_RUN_BACKEND_WARMUP_FAILED`（`stataPath` 写错时 Stata 照样加载了）。等待提示出现在 Output 日志里；测试用的输入方式不画 Terminal 面板，所以 Windows 上面板里的文字还没核实 |
| 两个活会话时的 `/panic-kill?dryRun=1` | `d020b036`，11-06 | 通过，2/2。每个窗口只选中自己的 4 个进程，两组不相交 |
| 两个活会话中对一个点 **Stata: KILL** | `d020b036`，11-06 | 范围通过，恢复失败。只有被 KILL 的窗口的进程树结束；另一个窗口的 pid 不变，下一条命令 rc 0。被 KILL 的窗口恢复 smoke 失败（`transport-failed`），下一条命令得到 HTTP 423 `panic-kill-command-needs-smoke`；见本节开头的说明 |
| PR #34 之后，两个活会话中对一个点 **Stata: KILL** | `80e01c8`，11-07 | 通过。只有被 KILL 的窗口的进程树结束（「ended 3 of 4 … already exited 1」）；点击后 77 s，被 KILL 的窗口显示「the verified recovery smoke passed; the session is READY」，换了新后端（`resetGeneration` 1），没关窗口，下一条命令 rc 0。另一个窗口的 pid 不变，下一条命令 rc 0 |
| KILL 恢复之后：Stata 报错，再由人按 Terminal Stop | `80e01c8`，11-07 | 通过。恢复后的窗口上 `display nosuchvar` 得到 `STATA_ERROR_CONFIRMED`，`stataRc` 111，下一条命令 rc 0。另一个窗口上人按 Terminal Stop 停 agent 的运行，得到 `STOPPED_NO_RETRY`，下一条命令 rc 0；两个窗口都以 `CLOSED` 关闭 |
| agent 交的报错命令（`display nosuchvar`） | `d020b036`，11-06 | 通过。`STATA_ERROR_CONFIRMED`、`stataRc` 111，12 项报错检查都为真，下一条命令 rc 0。Stata 日志里有 `r(111);`；扩展日志里没有报错文字 |
| 不输出的长命令（`bootstrap … reps(400) nodots`，没有日志输出） | `d020b036`，11-06 | 通过。跑了 192.8 s，rc 0，没有被取消；15 次采样里 14 次有 CPU 进展，0 次出错；`/status.watchdogCpu` 存在 |
| 后端被冻住时交的命令：失败、按 Stop | `d020b036`，11-06 | 通过。失败：51 s 后面板显示 `PRE_RUN_BACKEND_WARMUP_FAILED`，什么都没发出，下一条命令 rc 0。身份探针期间按 Stop：HTTP 409 `PRE_RUN_BACKEND_WARMUP_CANCELLED`，什么都没发出；`/soft-stop` 调用本身用了 58 s，会话一直锁着（见已知限制） |
| 第一条命令；真实 Terminal 面板里的等待提示 | `d020b036`，11-06 | 通过。`loadStataOnStartup` 为 `true` 和 `false` 时，开窗后马上交的 agent 命令都通过；`false` 时第一条 Terminal 命令 73.4 s 返回 rc 0。面板从 4.7 s 到 42.7 s 显示「Waiting for Stata to finish loading」，之后显示输出 |
| 人用 Terminal Stop 停 agent 的运行；`close` | `d020b036`，11-06 | 通过。`STOPPED_NO_RETRY`，`stoppedBy` 为 person，各项 stop 检查都为真，下一条命令 rc 0。6 次 `close` 都返回 `CLOSED` |

macOS Intel 和 Windows Server 2022 在每个 PR 的 CI 上跑离线测试和打包（没有授权的 Stata）。
Windows 10、Windows on ARM 和 Linux 未验证。

PR #15（Stop/KILL 提示与实际结果一致、Windows 进程存活判定、静默探针修复）已在 Windows 上用 `e7e54848` 实机复测
（表中 11-03 各行）。PR #17（`e9b22430`：开窗即加载 Stata、看门狗取消写明自己的停顿、迟到事件跟着自己的任务走）
已在 Windows 上用它的 head `3765d82a`（bundle 与 `e9b22430` 相同；表中标 `3765d82a` 的各行）实机复测。三项修复都成立，但 Stata 刚加载完就发的 Terminal 命令卡过一次。PR #18（`1bf02d02`：Terminal 命令派发前先等 Stata warm-up）
已在 Windows 上用它的 head `e5d2cda7`（源码树相同；表中 11-04 各行）实机复测，见[已知限制](#已知限制)。macOS 在 11-04 用 `v0.2.0-next.5` 发布版（`aba81779`）做了实机复测，
11-04 至 11-05 又在 `main` `b0bc49d`（PR #19–#21、#23–#26 之后，#27、#28、#22 之前）上复测了一次，发现的问题列在[已知限制](#已知限制)。
11-06 macOS 在 `d5b03df` 上、Windows 在 `main` `d020b036` 上复测（表中 11-06 各行）；11-07 在 PR #34 之后的 `main` `80e01c8` 上复测了 Windows（表中 11-07 各行）。

</details>

## 开发

文档检查包括 `git diff --check`、本地链接和 CLI 参数检查。运行时集成还需完成以下发布检查；
构建仅在本机或 CI 执行，禁止在生产或 VPS 服务器构建。

```sh
npm ci --ignore-scripts
npm run check -- --keep-going
python3 -B -m unittest discover -s tools -p 'test_*.py'
npm run package
python3 -B tools/verify_release.py --packaged
```

安装包名为 `stata-workbench-shared-session-<version>.vsix`。这些是验证命令，不表示本候选版已通过。
发布负责人重新生成 bundle 身份与运行时清单、检查精确 VSIX，并单独记录已授权机器的实机证据。
见 [CONTRIBUTING.md](CONTRIBUTING.md)、[发布维护](docs/RELEASE.md)和[CHANGELOG.md](CHANGELOG.md)。
历史 Next 操作文档维持原范围；普通窗口候选版请使用本 README 与[日常流程](docs/agent-daily-workflow.md)。

## 许可

AGPL-3.0-or-later。派生自 [tmonk/stata-workbench](https://github.com/tmonk/stata-workbench)。
与 [hanlulong/stata-mcp](https://github.com/hanlulong/stata-mcp) 的设计比较在 [NOTICE](NOTICE) 里致谢，
这并不表示两者的运行时可以互换。见 [LICENSE](LICENSE) 和 [SECURITY.md](SECURITY.md)。

不包含 Stata、Stata 授权、凭据或数据。bridge 只监听 `127.0.0.1`，不是远程服务，也不是多用户服务。
