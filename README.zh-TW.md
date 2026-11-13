# Stata Workbench 共享工作階段

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

<img src="media/icon.png" alt="Stata Workbench Shared Session 圖示" width="96">

> **0.2.0 候選版：交付進行中，尚未釋出。** 以下一般視窗工作流程描述的是候選版。
> 仍須針對確切安裝套件完成安裝、實機驗收，以及實際 Codex／Claude 宿主互動檢查。
> 下方保留的 Next 歷史結果不能證明這些項目已通過。

在 VS Code 裡，人和 AI agent 共用同一個看得見的 Stata 工作階段。模型執行時可以看輸出、
按 Stop、審閱程式碼修改提案，再決定接下來執行哪個已儲存的階段檔案。
資料、巨集、純量、估計結果和圖在工作階段內共享；關閉或重設前請先儲存結果。

- **兩個獨立分析視窗。** 在一般 VS Code 視窗中手動啟動，最多兩個工作階段；
  兩個視窗可以使用同一個設定檔。各自擁有 Stata 後端、連接埠、執行環境、暫存檔和檢查點。
- **看得見的協作。** 人和 agent 在同一工作階段內輪流操作；不同工作階段可平行執行不同模型。
- **由人審閱改稿。** agent 以 diff 提出 `.do`、`.ado` 或 `.mata` 修改；
  Accept 只寫入檔案，繼續執行需要使用者另下新指令。
- **回執與明確恢復。** 執行結果不明時不會自動重試；恢復失敗會讓工作階段維持封鎖。

派生自 [tmonk/stata-workbench](https://github.com/tmonk/stata-workbench)
（AGPL-3.0-or-later），見[授權條款](#授權條款)。

## 專案導覽

| 儲存庫 | 角色 |
| --- | --- |
| [Shared Session](https://github.com/lzhs1995/stata-workbench-shared-session) | 執行環境主線與版本釋出 |
| [操作技能](https://github.com/lzhs1995/stata-workbench-shared-session-skill) | 獨立版本的 agent 指南與執行環境相容檢查 |
| [Next](https://github.com/lzhs1995/stata-workbench-next) | 開發分支與歷史預覽版證據 |

三個儲存庫各自維護版本與釋出週期。請依相容紀錄選用執行環境和技能；
Next 是獨立預覽版，不會取代既有的研究工作階段。

## 目錄

- [候選版識別資訊](#候選版識別資訊)與[環境要求](#環境要求)
- [安裝](#安裝)與[快速上手](#快速上手)
- [Agent 日常流程](docs/agent-daily-workflow.md)與 [AGENTS.md](AGENTS.md)
- [功能](#功能)、[設定](#設定)、[疑難排解](#疑難排解)
- [已知限制](#已知限制)與[平台實測結果](#平台實測結果)
- [開發](#開發)與[授權條款](#授權條款)

## 候選版識別資訊

| 項目 | 0.2.0 候選版 |
| --- | --- |
| 擴充套件 ID | `lzhs1995.stata-workbench-shared-session` |
| 手動入口 | 在目標一般視窗執行 **Stata: Start Shared Session** |
| 狀態根目錄 | `~/.stata-workbench`；可用 `STATA_WORKBENCH_HOME` 指定 |
| 工作階段登錄檔 | `<state-root>/sessions/<sessionId>.json` |
| 本機連接埠 | 自動分配；透過工作階段登錄檔查詢 |
| 並行上限 | 最多兩個獨立工作階段；每個工作階段一次執行一個請求 |
| Agent 用戶端 | 已安裝擴充套件內的 `tools/workbench_agent.py` |

Next 仍是開發分支。隔離啟動器、五工作階段測試、`~/.stata-workbench-next` 根目錄
和 Next 擴充套件 ID 都屬於歷史預覽版，不能當作一般視窗的設定方式。
操作技能獨立維護版本；舊 rc.7.45 相容紀錄不能證明 0.2.0 相容。
請勿在目標視窗同時啟用 Shared Session 和 Next。

## 環境要求

使用本機 macOS 或 Windows 視窗、已授權的 Stata、VS Code 1.75 或更新版本，
以及 Python 3.10 或更新版本來執行隨附的 agent 工具。
相符的 Stata 服務執行環境必須事先備妥：Python 3.11、`mcp-stata==1.26.1`
和相容的 MCP 1.x（儲存庫限制檔指定 `mcp==1.28.1`）。
安裝 VSIX 並不代表這些相依套件已存在或能正常運作。

macOS 的預設執行環境位置是 `~/.local/share/stata-workbench/mcp-stata-1.26.1`；
Windows 是 `%LOCALAPPDATA%\stata-workbench\mcp-stata-1.26.1`。
每個啟動的視窗依下列順序選一個來源，複製成自己的執行環境副本：

1. `stataMcp.runtimeRoot` 設定（工作區資料夾、工作區、使用者依序優先）；
2. MCP server `env` 中的 `MCP_STATA_RUNTIME_ROOT`，其次是 VS Code 行程環境中的同名變數；
3. 以虛擬環境自身的 Python 用 `-m mcp_stata` 啟動的 server（`<venv>/bin/python3`，Windows 為
   `<venv>\Scripts\python.exe`）；
4. 上述受管執行環境；server 為標準 `uvx ... mcp-stata` 啟動或沒有 MCP 設定時也使用它。

計算副本大小之前，先以一次隔離的中繼資料查詢（`python -I -B`，不匯入 `mcp_stata`、不啟動 Stata）
核對來源：必須是以該資料夾為自身 prefix 的虛擬環境，並含 `mcp-stata==1.26.1` 與 MCP 1.x。
明確指定的來源核對失敗時直接停止並說明原因，不改用其他來源。其他啟動方式（例如 base Python
執行自訂 wrapper 腳本）會回報 `RUNTIME_SOURCE_UNSUPPORTED`；不必修改原 MCP 設定，在目前工作區
設定 `"stataMcp.runtimeRoot"` 為已驗證的 mcp-stata 1.26.1 虛擬環境絕對路徑即可。複製**完成後**，macOS 必須至少保留
20 GiB、Windows 至少保留 10 GiB 可用空間；不足時拒絕準備。
這些是候選版要求，不是本候選版已通過實機測試的聲明。

## 安裝

1. 向交付負責人取得本機提供、經審閱的 `stata-workbench-shared-session-0.2.0.vsix`
   和完整 SHA256。目前沒有宣告可用的公開 0.2.0 釋出網址。
   macOS 使用 `shasum -a 256 /absolute/path/to/file.vsix`；Windows 使用
   `(Get-FileHash 'C:\absolute\path\file.vsix' -Algorithm SHA256).Hash.ToLower()`。
   安裝前將完整值與經審閱的交付值核對。
2. 在準備使用的一般 VS Code 設定檔中，選擇 **Extensions → Install from VSIX…**，
   並選取該檔案。請使用目標視窗；若要求重新載入，先完成既有工作並儲存資料。
   安裝成功不代表已啟用、相依套件已備妥或實機已就緒。
3. 開啟本機專案資料夾，只對可信任的資料夾授予工作區信任。
   將 `stataMcp.loadStataOnStartup` 維持為 **false**，也要檢查繼承的使用者／工作區設定。
   若找不到 Stata，請設定 `stataMcp.stataPath`。
4. 在命令選擇區手動執行 **Stata: Start Shared Session**，連線到此視窗的工作階段並開啟
   Terminal。開啟無關視窗不應啟動 Stata 引擎。第二個獨立模型可在另一個一般視窗手動啟動；
   不需要特殊啟動器或另建設定檔。

若執行環境缺少或不相符，請依設定錯誤停止，在備妥相符環境後再 Start。
本候選版未宣稱會自動安裝相依套件，也未宣稱已完成全新機器的設定驗收。

## 快速上手

人可使用 **Stata: Run Current File**（macOS `Cmd+Shift+D`、Windows `Ctrl+Shift+D`）、
**Stata: Run Selection/Current Line** 或 Stata Terminal，在該視窗查看執行輸出與身分。

Shell agent 使用已安裝擴充套件隨附的工具。Code CLI 已在 PATH 時，macOS 可這樣尋找：

```sh
WB_EXTENSION="$(code --locate-extension lzhs1995.stata-workbench-shared-session)"
WB_AGENT="$WB_EXTENSION/tools/workbench_agent.py"
python3 -B "$WB_AGENT" sessions
```

Windows PowerShell，先確認使用的已安裝 Python 路徑：

```powershell
$WbPython = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python314\python.exe'
$WbExtension = (code --locate-extension lzhs1995.stata-workbench-shared-session).Trim()
$WbAgent = Join-Path $WbExtension 'tools\workbench_agent.py'
if (-not (Test-Path $WbPython) -or -not (Test-Path $WbAgent)) { throw 'Check Python and the installed Workbench path' }
& $WbPython -B $WbAgent sessions
```

使用與目標設定檔相符的已安裝版本，不要任選一份原始碼副本。
選定屬於目標工作區／視窗的確切 `sessionId`，將 `SESSION_ID` 和 `/abs/...` 換成實際值。
來源檔案必須已儲存在該工作區內，每次執行都使用新的 workflow 目錄。
Windows 在 `& $WbPython -B $WbAgent` 後使用相同引數，路徑改為 Windows 絕對路徑。

```sh
python3 -B "$WB_AGENT" status --session SESSION_ID
python3 -B "$WB_AGENT" run --session SESSION_ID --file /abs/project/stage01.do --cwd /abs/project --workflow-dir /abs/receipts/stage01 --agent-name Codex
python3 -B "$WB_AGENT" status --workflow /abs/receipts/stage01
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01
```

Claude Code 使用 `--agent-name 'Claude Code'`。`run` 啟動本機 worker 後即返回，
agent 可以繼續接收使用者指令。查詢或提交的退出碼為 0 不代表執行 PASS：
請檢查 `state` 與原始回執的 `verdict`。只有 `PASS_VISIBLE_SHARED_RUN` 能確認受檢查的執行；
統計結果是否正確仍須審閱輸出。執行結果不明時不得重新提交。
回執包含私有來源程式碼與輸出，請保留在本機。

使用者說「停下來」時：

```sh
python3 -B "$WB_AGENT" stop --workflow /abs/receipts/stage01 --user-action 'stop it'
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01
```

持續觀察原 workflow，直到確認已暫停、恢復且就緒。只取消 agent 宿主操作不會停止
Workbench worker；已寫出的外部檔案也不會回復。
原執行尚未可見時，Stop 的有限重試規則見[日常流程](docs/agent-daily-workflow.md)。

把提議的新內容放在另一個檔案，不能先覆寫目標：

```sh
python3 -B "$WB_AGENT" propose-edit --workflow /abs/receipts/stage01 --content-file /abs/proposals/stage01-proposed.txt --reason 'Apply the requested model change'
python3 -B "$WB_AGENT" reconcile --workflow /abs/receipts/stage01 --proposal-id RETURNED_PROPOSAL_ID
```

提案修改的是該 workflow 的原始來源檔案。人在 diff 中選擇 **Accept** 或 **Reject**。
若人改為直接編輯原始緩衝區，請等其儲存後重新提案；未儲存、版本或 SHA 衝突會拒絕舊提案。
**Accept 只寫入檔案。** 確認暫停後，使用者的新指令可以明確指定要繼續執行的已儲存階段：

```sh
python3 -B "$WB_AGENT" continue --workflow /abs/receipts/stage01 --file /abs/project/stage03.do --workflow-dir /abs/receipts/stage03-continued --user-action 'Continue only the saved stage03.do'
```

這只會**從頭執行**選定的檔案，沿用父 workflow 的工作目錄，不會推測從哪一行續跑。
分階段任務每次提交一個檔案並檢查其回執；執行下一階段前，先處理尚未儲存的修改。
完成後儲存需要的資料，再透過 VS Code 關閉目標視窗；不能為了關閉一個工作階段而終止共用的 Code 程序。

## 功能

每個工作階段讓人與 agent 共用 Stata 狀態及即時輸出，同一階段內的請求依序執行；
目標忙碌時不會改投另一個視窗。私有登錄檔與驗證身分的 bridge 綁定工作階段、
generation 和已安裝的 bundle。隨附 CLI 提供 `sessions`、`status`、`run`、`stop`、
`propose-edit`、`reconcile`、`continue` 七個操作。

<a id="agent-改-stata-檔案要經人審閱"></a>

改稿提案會檢查工作區實際路徑、未儲存緩衝區、文件版本和檔案 SHA，設定到期時間，
並保留原始快照。接受提案不會執行程式。agent 必須透過此流程修改 Stata 來源檔；
這些宿主操作規則本身不構成作業系統寫入沙箱。

Stop 會嘗試恢復 agent 執行前的檢查點；人自己的執行可能沒有檢查點。
恢復失敗時工作階段保持封鎖。**Stata: KILL** 是不同的恢復操作，可能遺失記憶體內資料，
需要使用者知情確認；清理結果不明不能算成清理完成。

## 設定

| 設定 | 目前一般視窗的使用方式 |
| --- | --- |
| `stataMcp.loadStataOnStartup` | 維持 `false`，手動啟動 |
| `stataMcp.visibleBridgePort` | `0` 表示自動分配；明確指定的連接埠必須獨佔 |
| `stataMcp.stataPath` | 必要時指定本機已授權的 Stata 執行檔 |
| `stataMcp.sourcePathMappings` | 只使用明確映射，見[路徑映射指南](docs/source-path-mappings.md) |
| `STATA_WORKBENCH_HOME` | 絕對狀態根目錄，預設 `~/.stata-workbench`；VS Code 與 shell 必須一致 |

CLI 也接受放在子命令**之前**的 `--state-root /absolute/path`，用來選擇既有的工作階段登錄目錄，
不會啟動或搬移工作階段。此流程請清除舊 `STATA_WORKBENCH_NEXT_HOME`。
各工作階段的執行環境、檢查點與暫存檔都在 `<state-root>/runs/<sessionId>/`。
不要複製 token，也不要手改工作階段擁有者紀錄。

## 疑難排解

| 狀況 | 處理方式 |
| --- | --- |
| `sessions` 沒有目標工作階段 | 核對已安裝擴充套件、設定檔及狀態根目錄；在目標視窗手動 Start |
| `SESSION_LIMIT` | 已有兩個引擎或尚未確認清理的名額；完成／關閉指定工作階段並核對清理結果，不要刪除名額檔案 |
| `RUNTIME_SOURCE_MISSING`／相依套件錯誤 | 備妥相符的服務執行環境；只安裝 VSIX 並不足夠 |
| `RUNTIME_SOURCE_UNSUPPORTED`／`RUNTIME_SOURCE_INVALID`／`RUNTIME_INVALID` | 在工作區設定 `stataMcp.runtimeRoot` 為已驗證的 mcp-stata 1.26.1 虛擬環境絕對路徑；錯誤訊息會寫出被拒來源與受管路徑 |
| `DISK_RESERVE` | 準備執行環境副本前，先恢復要求的可用空間 |
| 身分／bundle 不相符 | 使用相符的已安裝工具並檢查原視窗；不要繞過檢查或改投別處 |
| `unknown-no-retry`／`EXECUTION_UNCONFIRMED_NO_RETRY` | 核對原 workflow 與回執，不要盲目重新提交 |
| 提案發生未儲存／版本／SHA 衝突 | 保留人的緩衝區，等其儲存後重新提案 |
| 需要恢復／HTTP 423 | 停止相依工作，檢查原回執與視窗。KILL 需要使用者知情確認資料損失；不能繞過恢復檢查 |
| 關閉中或清理未完成 | 保留證據並調查確切歸屬的工作階段；清理不明不代表可以結束共用 Code 或其他 Stata 程序 |

## 已知限制

**0.2.0 一般視窗套件尚未完成交付驗收。** 仍須針對確切套件完成 macOS／Windows 安裝、
同一設定檔下的雙視窗隔離、實際 Codex／Claude 尋找與執行、由人操作 diff 的
Accept／編輯／繼續，以及 Stop 和恢復／關閉檢查。離線測試、安裝成功與 Next 歷史實測
都不能證明這些項目已通過。本指南沒有安裝宿主原生 Stop／diff／continue hook。
遠端擴充套件宿主、Linux 和其他未列明的系統版本尚未驗證。

<details>
<summary>Next 歷史限制與修正——僅對應原始建置版本</summary>

以下保留原 Next 建置版本及隔離啟動器的紀錄。其中的「main」、五工作階段、啟動旗標和
設定目錄都是歷史資訊；不能把這些設定／恢復做法套用到 0.2.0 一般視窗。

`main` 上已修復（`e9b22430`，PR #17），並已在 Windows 上用 `3765d82a`（11-03）實機確認，另有註明的除外：

- **Windows：開窗後的第一條命令曾經會把工作階段鎖住（剩下的卡頓由下面的 warm-up 修復處理）。** `stataMcp.loadStataOnStartup: false` 時，Stata 要等第一條命令來了才載入。在 Windows 上，這第一條命令 3 次卡了 2 次，約 120 s 後回傳 HTTP 504，工作階段被鎖。啟動器現在預設寫 `true`，Stata 在開窗時就載入（Windows 11 上 57.7 s）。設定目錄裡顯式寫了 `false` 的，問題照樣會出現（最後一次在 `3765d82a` 上核過）；啟動器保留這個值，`open` 的回包會在 `backendLoad` 裡說明。這樣的工作階段被鎖後點 **Stata: KILL** 解鎖；要避免，就在 `open` 之前把 `profiles/<名字>/user-data/User/settings.json` 裡的 `false` 刪掉。到目前為止的測試裡，macOS 沒有這個問題。
- **被取消命令的遲到事件曾經記到別的執行上。** 在 Windows 上，一條取消已報「確認」的命令約 2 s 後照樣執行了，它遲到的紀錄事件被交給了緊接著的那次執行（靜默探針）。當時工作階段是鎖住的，沒人在錯誤狀態上接著做；PR #15 之後，這種回包報 `EXEC_OUTCOME_UNKNOWN` 並帶 `payloadMayHaveRun: true`（已在 Windows 上用 `e7e54848` 實機確認）。PR #17 讓事件跟著自己的任務走：一次執行沒等到回包就結束後，task id 不明的事件不再交給目前執行，而是暫存或丟棄。暫存區最多 256 條；如果 256 條全是 `log_path` 或 `task_done`，新來的 `task_done` 可能被丟。
- **看門狗取消曾經顯示上一次失敗的原因。** 在 agent 路徑上，看門狗取消之後的狀態沿用了之前一次 Terminal 失敗的原因和時長。現在每次取消都寫自己的 `stallReason` 和 `elapsedMs`，鎖定原因寫成例如 `EXEC_PRELOG_STALL (IDLE)`。`reasonCode` 本身對各種停頓仍都是 `EXEC_PRELOG_STALL`，因為用戶端按它匹配。

`0.2.0-next.5` 之後在 `main` 上修復的，有離線測試和 CI。macOS 在 `main` `b0bc49d`（#27、#28、#22、#30、#31 之前）上做了實機複驗，PR #30 另在它的最終 head `8739778` 上測過，PR #31 在最後一輪複核返工之前的 head 上測過。11-06 macOS 在 `d5b03df`（合併後的 bundle）上、Windows 在 `main` `d020b036` 上複驗，結果寫在各條裡：

- **Windows：Stata 載入完後的第一條 Terminal 命令偶爾卡住（W-P1）。** 分段計時（PR #21）找到了卡在哪裡。33 次裡卡住的那 1 次，worker 裡 Stata 自己的啟動在 pre-flight 檢查之後、到 `stata_setup.config` 結束之間用了 76.6 s（其餘 32 次是 3.4–8.6 s）。命令一直在排隊，沒有丟：舊建置版本把這段等待算進了命令的 120 s 首條紀錄預算，在 Stata 就緒前 1.7 s 把它取消了。PR #18 起，命令先在這個預算之外等 Stata 載入完（預設最多 300 s）。帶這段等待的建置版本 24 次 0 次卡住，其中 10 次是新建設定目錄。這是統計上限（95% 信賴水準下卡住率低於約 12.5%），不能證明不會再卡。Stata 啟動超過上限時，命令在派發前被拒絕（`PRE_RUN_BACKEND_WARMUP_TIMEOUT`），工作階段不會被鎖。
- **不輸出的長命令 60 s 後會被取消**（繼承自穩定版）。看門狗現在還把本視窗自己的 Stata worker 用掉的 CPU 時間算作進展（PR #24，rc.7.84）。限制見下面的 CPU 訊號一條；11-04 macOS 複驗時，高負載下這樣的命令仍被取消了，起因是 CPU 取樣失敗；PR #31 改了這一點（見下面）。
- **後端 connect 完成之前按 Stop 會鎖住工作階段。** 現在只拒絕這條命令，不鎖工作階段（PR #25，rc.7.83）。
- **同時跑的幾個 `open` 會在 10 s 後互相超時。** 現在都在短鎖裡預留、鎖外啟動（PR #23）。
- **剛開窗時 agent 的提交會被拒**（`BLOCKED_NO_DISPATCH`），而 Terminal 命令會等。現在 agent 也等同一個 warm-up；拒絕結果帶 `retryable` 和 `retryAfterMs`（PR #26，rc.7.86）。
- **warm-up 快取可能信任一個已被換掉的 worker。** 現在快取記下 worker 的 pid、啟動時刻和 transport，用之前再核一次；核對失敗或超時就當作沒就緒。worker 在啟動中掛掉時，Terminal 命令會把它重啟一次（PR #20，rc.7.81）。
- **Stata 報錯被報成結果不明。** 確認了的報錯現在給 agent 回傳 `STATA_ERROR_CONFIRMED` 和 Stata 的回傳碼（`stataRc`），Terminal 路徑也報這個回傳碼，不再是 -1（PR #27，rc.7.85；PR #28 讓 mcp-stata 發出回傳碼）。已在 macOS 的 `b82203d` 和 `d5b03df` 上實機驗證，Windows 在 `d020b036` 上驗證了 agent 路徑，見下面的限制。
- **Windows 上的 Stata: KILL 曾經結束本機所有 Stata 圖形介面行程和所有 mcp-stata 後端**，不只是本工作階段的；忙時的強制重置也一樣。現在只結束本視窗已確認的後端行程樹（PR #22，rc.7.82）。在 `d020b036` 上用兩個工作階段實機跑過一次，確認了範圍：只有被 KILL 的視窗的行程樹結束，另一個視窗的 pid 不變、下一條命令照常執行。Windows 上那次 KILL 之後的恢復失敗，見[平台實測結果](#平台實測結果)開頭的說明和下面的限制。
- **人自己的 Run File 停不下來。** 它的進度通知「Running <檔案> [Cancel]」蓋住了 Terminal 的 Stop 按鈕（`b0bc49d` 的 macOS 複驗），通知的 **Cancel** 又沒有接到任何操作，執行一直到 375 s 被看門狗取消，工作階段被鎖。現在 Run File 或 Run Selection 通知裡的 **Cancel** 呼叫和 Terminal 按鈕同一個 Stop，只在開啟通知的那次執行還在進行時生效（同一個執行生命週期、同一個 request id）（PR #30，rc.7.87）。Run File 已在 macOS 的 `8739778` 上實機核過；Run Selection 只有單元測試。舊通知的 Cancel 停不了之後的新執行、也停不了接手的 agent 執行，這一點只有離線測試；11-06 實機核對時造不出這種狀態（舊通知總在新執行的通知出現前就關了）。
- **人停掉 agent 的執行，agent 拿到的是 `EXECUTION_UNCONFIRMED_NO_RETRY`。** 現在人在 VS Code 裡用 Terminal 的 Stop 按鈕或 **Stata: Cancel Current Request** 停掉 agent 的執行，agent 拿到 `STOPPED_NO_RETRY`（退出碼 2，不重試）。Run File 和 Run Selection 的通知屬於人自己的執行，停不了 agent 的執行。用戶端只在這些條件都成立時才給它：這次 Stop 屬於本次請求和本次執行，發生在這次提交之後，同一次 Stop 恢復了這次執行的執行前檢查點（同一個 run id、`restored` 為 true、reset generation 相同），工作階段重新就緒（PR #30）。已在 macOS 的 `8739778` 上用 Terminal 的 Stop 按鈕實機核過；**Stata: Cancel Current Request** 沒在 agent 的執行上實機試過。`b0bc49d` 複驗裡 Stop 之後約 2 s 出現的 HTTP 423 `checkpoint restore in progress`，來自經測試端點 `/debug-terminal-input` 發的命令；agent 用戶端要等工作階段就緒才傳送。
- **人輸入的報錯命令卡片標題是普通的「Stata Output」。** 現在和 agent 一樣顯示「Stata Output (failed)」（PR #30）。
- **高負載下，一次 CPU 取樣失敗就可能讓不輸出的長命令被取消。** worker CPU 時間的取樣失敗、過期或超時，會重置看門狗的 CPU 基線，相隔約 12 s 的兩次失敗就可能空出 60 s 以上不算進展，而 worker 其實一直在算。11-04 macOS 複驗時（負載均值約 200），`bootstrap _b, reps(400) nodots` 在 99 s 被取消。現在這樣的取樣不算進展，但保留基線，並按型別計數（`cpuErrorKinds`）。算進展仍要同一棵行程樹的兩次核實過的取樣；行程樹變了或有新紀錄，基線照樣重置（PR #31，rc.7.88）。`/status.watchdogCpu` 給出正在執行的守衛，以及最近一次 agent 和 Terminal 守衛的這些計數。在 PR head `db105f28` 上，負載均值 61–76 時三條不輸出的 `bootstrap` 都以 rc 0 完成，沒有取樣出錯。觸發取消的那種高負載沒有重現，所以這項修復在那種負載下只有單元測試支撐。11-06 在 macOS（`d5b03df`）上一條 105 s 沒有輸出的 `bootstrap` 有 CPU 進展、沒有取樣出錯地完成了，Windows（`d020b036`）上一條 192.8 s 沒有紀錄輸出的執行也一樣。
- **macOS：命令執行中點 KILL 或強制重置，舊的 Stata worker 曾經會以父行程 pid 1 繼續執行**，而 `/status` 和 `close` 都報告工作階段是乾淨的（`b82203d`，11-05）。KILL 和強制重置只結束 `mcp-stata` 服務行程，worker 只有在服務行程正常退出時才會跟著退出。現在強制重置先對後端行程樹拍一次 `ps` 快照：根行程必須是登記的 pid，是本擴充套件宿主的直接子行程，啟動不晚於登記後 5 s。結束服務行程之後，只對記下的、仍滿足以下條件的後代先發 SIGTERM 再發 SIGKILL：啟動時刻不變，工作目錄在本工作階段的 workspace 或 `mcp-temp` 裡，父行程是 pid 1 或記下的父行程。讀不到或確認不了的情況，例如登記讀不出、存活檢查出錯、有第二個活後端或一個活後端都沒有，都在 `/status.orphanWorkers` 裡列為 unresolved，不發訊號，也不報乾淨（PR #31，rc.7.89）。`close` 只報告，除了 VS Code 視窗之外不發任何訊號。結果裡有 `leftoverProcesses`、`orphanWorkers` 和 `orphanCleanup`（`mode: "report-only"`、`signalled: []`、`clean`、`unresolved`、`holders`）。行程讀取失敗、超時、往 stderr 輸出或只回傳部分結果時，都算「不明」，不算「空」。只有沒有 unresolved、而且對工作階段檔案的最後一次掃描讀成功並且沒有佔用者時，`clean` 才為 true。在最後一輪複核返工之前的 PR head `4a1ac2e` 上實機（macOS，11-05）：一條不輸出的命令跑到 20 s 時點 KILL，舊 worker 和它的 resource tracker 被結束；同一工作目錄裡一個命令列含 `spawn_main` 的測試行程沒有收到訊號，一次 `close` 把它列為 unresolved。之後那輪返工（堵上可能被讀成乾淨的幾種情況）有離線測試和變異測試。合併後的程式碼在 `d5b03df` 上複驗（11-06）：不輸出的命令執行中點 KILL，舊 worker 和它的 resource tracker 再次被結束，測試行程沒被動。那次複驗發現了下面兩條裡的缺陷。
- **macOS：`close` 在真實 workspace 上列不出活著的 worker 或佔用者**（11-06 複驗）。只要資料夾裡有一個沒有行程開啟的檔案，`lsof +d <workspace>` 就以退出碼 1 結束，同時照樣輸出它找到的行程。#31 把這種情況算作「不明」，所以在任何真實 workspace 上 `close` 都報 `identity-unreadable` 和 `holders: unknown`。現在目錄掃描在退出碼為 0 或 1 且 stderr 為空時讀取這些行；其他退出碼、有 stderr 輸出（比如打不開的資料夾）或超時仍算「不明」（PR #32）。只在 macOS lsof 4.91 上實機核過：一個佔著 workspace 的測試行程被列為 unresolved（`holders: present:1`、`clean: false`、什麼訊號都沒發）。`close` 仍然只報告、盡力而為，見下面的限制。
- **macOS：有後端行程被停住時，強制重置會帶走 VS Code 的擴充套件宿主**（11-06 複驗，4 次都出現）。本視窗的 Stata worker 被 SIGSTOP 停住時，看門狗取消升級為強制重置；服務行程結束約 1 s 後，擴充套件宿主退出（code 0），只剩 VS Code 主行程。原因有實測強力支援，但沒有直接觀測到（沒有抓到 SIGHUP）。在所測的啟動方式下（macOS，由 `tools/stata_session.py` 用隔離設定目錄啟動的視窗），視窗的所有行程，包括 mcp-stata 服務行程、它的 resource tracker 和 worker，都在 VS Code 主行程的行程群組裡。服務行程退出後，tracker 和 worker 被過繼給 launchd，仍留在這個組裡。這樣的成員退出時如果組裡還有別的成員被停住，核心就把這個組當作孤兒行程群組，向整個組發 SIGHUP 和 SIGCONT：擴充套件宿主和各個輔助行程結束，VS Code 主行程活下來。rc.7.89 的清理在 worker 被停住時結束了已過繼的 tracker，觸發了這一點。現在清理在每次發 SIGTERM 或 SIGKILL 之前先讀宿主的行程群組。被停住、且與記下的身分（pid 和啟動時刻）一致的成員先收到 SIGCONT，然後再讀一遍行程群組。有不是我們的成員被停住（`host-group-stopped`）或讀不到行程群組（`host-group-unknown`）時不發訊號，這一行保持 unresolved。每次讀完行程群組之後、每次發 SIGCONT 之前都檢查截止時間、取消和更新的重置（PR #33，rc.7.89-v4）。在 PR #33 的第一個 head `3c8e4f3` 上實機 2/2：宿主活了下來，**Stata: KILL** 解鎖了工作階段，下一條命令 rc 0，`close` 回傳 `CLOSED`；其中一次有一行 `host-group-unknown`，原因沒查到。新加的停止檢查只有離線測試和變異測試。
- **Windows：KILL 成功之後，視窗一直拒絕執行**（11-06 複驗）。命令在它剛結束掉的那個後端的連線上跑恢復 smoke，smoke 以 `transport-failed` 失敗，下一條命令得到 HTTP 423 `panic-kill-command-needs-smoke`；測試隨後關掉了視窗（沒有試第二次 KILL 或 `POST /recovery-smoke`）。現在範圍內的 KILL 成功後會先做一次強制重置：沿用這次 KILL 記下的結果，開啟新連線，工作階段保持「需要 smoke」；smoke 隨後在新連線上跑（PR #34，rc.7.90）。fail-closed 路徑和部分結束的情況不變。在 `main` `80e01c8` 上實機（11-07）跑過一次，兩個工作階段：被 KILL 的視窗自己恢復，下一條命令 rc 0；另一個視窗不受影響。

目前 `main` 上還沒解決的問題：

- **Stata 還在載入時交的命令。** `trueReady` 不等背景載入。Terminal 命令和 agent 的提交都會先等 Stata worker 進入 running；等過 2 s，Terminal 顯示「Waiting for Stata to finish loading…」，點 Terminal 的 Stop 按鈕或用 `POST /soft-stop` 都可以取消等待。等滿 300 s 或 warm-up 失敗時，命令在發出之前就被拒絕（`PRE_RUN_BACKEND_WARMUP_TIMEOUT` 或 `PRE_RUN_BACKEND_WARMUP_FAILED`，`payloadDispatched=false`）。只有不提供 `list_sessions` 的舊版 mcp-stata 才不經這項檢查直接放行（這是相容做法，不能證明 Stata 已就緒）。有 `list_sessions` 但連續失敗或超時時，warm-up 以 `FAILED` 結束，命令被拒絕；warm-up 剛結束時 worker 變了或確認不了，命令會再等一次，仍不行就拒絕。11-04 在 macOS 上實機確認了等待提示、等待中 Stop（經 `/soft-stop`）、超時和失敗拒絕；Windows 上確認了除失敗拒絕以外的幾項，等待提示只在 Output 紀錄裡核過；11-06 在 Windows（`d020b036`）上，失敗拒絕和真實 Terminal 面板裡的等待提示也都看到了。11-05 在 macOS（`b0bc49d`）上往 Terminal 面板裡輸入命令，等待期間 Stop 按鈕是可用的；點它之後命令以 `PRE_RUN_BACKEND_WARMUP_CANCELLED` 被拒絕，什麼都沒發出，下一條命令 rc 0。之前說「等待期間 Stop 按鈕被禁用」，來自一個測試端點（`/debug-terminal-input`）：它發命令時不經過面板的 Run 處理，面板就一直沒顯示命令在執行。這不是產品缺陷。
- **Windows KILL 的範圍只有兩次實機執行支援。** 在 `d020b036` 和 `80e01c8` 上各用兩個工作階段跑過一次：對視窗 A 點 KILL 只結束了 A 的後端行程樹，視窗 B 的 pid 不變，下一條命令 rc 0。兩次執行不構成統計上限。根行程按登記時刻（1 s 以內）認定，不是按記下的建立時間；身分比到毫秒；行程列表不是原子快照；結束之後只再掃一遍直接子行程。清理失敗或讀不到行程身分時，工作階段保持未就緒，`/recovery-smoke` 回傳 HTTP 423 `unresolved-cleanup`。
- **Windows：後端完全凍住時按 Stop 會鎖住工作階段。** 一個工作階段的後端行程全部被掛起時，`/soft-stop` 用了 58 s，回傳 500（`RECOVERY_FAILED`：靜默探針 5 s 超時），並強制重置了本工作階段自己的行程樹。之後工作階段一直以 HTTP 423（`soft-stop-needs-smoke`）拒絕命令，直到關掉視窗。紀錄給出的辦法是 **Stata: KILL** 或 `POST /force-reset`；在凍住的工作階段上兩者都沒試。PR #34 之後，KILL 成功時會在 smoke 之前重置連線，但這種 Stop 之後再 KILL 還沒有實機試過。慢但還活著的後端沒測。
- **Windows：在面板裡輸入、warm-up 期間被拒的命令，`/status.lastTerminalGuardFailure` 為空。** 拒絕只顯示在面板和紀錄裡。
- **macOS 的 KILL 和強制重置只按 pid 認後端**（PR #22 只改了 Windows）。 清理時，登記的 pid 的命令列裡含 `mcp-stata` 就結束它，不核對行程啟動時刻和父行程。如果這個 pid 正好被別的工作階段的 `mcp-stata` 複用，有可能被誤結束。
- **macOS 孤兒 worker 清理的限制。** 訊號發給裸 pid：一個行程在最後一次核對之後退出、它的 pid 在發訊號前被複用，這種情況排除不了；啟動時刻也只精確到 1 s。根行程規則是單邊的：本擴充套件宿主的另一個子行程如果在登記後 5 s 內拿到登記的 pid，排除不了。`close` 的收集和報告兩段各有 8 s 時限，管的是清理的行程讀取，不是整個呼叫：高負載下 `close` 仍可能在列執行個體時因 `ps` 超時拋錯，而不是回傳結論。收集時間用完的行一直記為 unresolved，即使那個行程之後正常退出了。`close` 已實機列出過一個佔著 workspace 的測試行程（11-06），還沒有列出過比視窗活得更久的真實 Stata worker：11-05 的測試裡 worker 總是隨 VS Code 退出而結束；11-06 一個用 SIGSTOP 停住的 worker 有一次比視窗活得更久，但當時那個建置版本的 `close` 列不出它（PR #32 已修），其餘幾次它都在退出過程中結束了。`close` 只報告、盡力而為：它只掃 workspace 資料夾和直接放在裡面的檔案（`lsof +d` 不遞迴），行程讀取不是原子的，而且只在 macOS lsof 4.91 上核過，所以 `holders: none` 和 `clean: true` 的意思是在這個範圍裡沒看到。自己動手結束行程之前，先用 `ps -o pid,ppid,lstart,command -p <pid>` 核對 unresolved 的那一行。Windows 不變（那裡 PR #22 結束本視窗整棵後端行程樹），這種情況沒在 Windows 上測過。
- **macOS：視窗裡另有行程被停住時，KILL 或清理不受支援。** PR #33 只保證強制重置不會在我們記下的行程被停住時結束組裡的成員。如果視窗裡的某個行程是被外部停住的（SIGSTOP、偵錯程式），之後的 **Stata: KILL** 或清理仍可能以同樣方式帶走擴充套件宿主（實機見過）。視窗裡一個被停住、但不是記下身分的行程會擋住清理（各行 unresolved），它不會被恢復。最後一次讀行程群組到發訊號之間 pid 被複用、或行程又被停住，這些情況排除不了。
- **worker CPU 訊號是一種近似。** CPU 在跑不等於在做有用的事：一直空轉、不輸出的執行，最多能佔著工作階段到紀錄連續 30 分鐘沒動靜為止。核實不了行程樹時（取樣期間有 pid 退出、超過 4 層或 16 個行程、父行程對不上），這次取樣不算進展，照 60 s 紀錄規則判斷。同一秒內的 pid 複用超出它所核對的啟動時刻的精度。11-04 在 macOS 上複驗 `main`（`b0bc49d`）：一條 57 s 不輸出的執行以 rc 0 完成，被凍結的 worker 仍被取消；高負載下一條更長的不輸出執行被取消了（見下一條）。
- **最高負載下不輸出的長命令，PR #31 之後還沒有實機複驗。** 11-04 的那次取消（負載均值約 200，99 s，`cpuErrors=2`）來自 CPU 取樣失敗重置了基線，PR #31 改了這一點（見上面已修復的一條）。11-06 不輸出的執行在 macOS（105 s 沒有輸出）和 Windows（192.8 s）上都有 CPU 進展地完成了，但那種負載和那些取樣失敗沒有重現，所以針對它們的修復只有單元測試支撐。看門狗取消之後工作階段仍會鎖住（HTTP 423 `guard-cancel-needs-smoke`），直到點 **Stata: KILL**；這個鎖是有意的，因為取消之後 Stata 裡的狀態是未知的。
- **人跑 Run File 或 Run Selection 時的進度通知會蓋住 Terminal 的 Stop 按鈕。** 通知裡的 **Cancel** 現在能停下執行（見上面已修復的一條）。點通知的正文沒有作用；Run Selection 上的 Cancel 只有單元測試；兩者都沒在 Windows 上核過。舊通知的 Cancel 停不了更新的執行，這一點只有離線測試：11-06 實機試了三次，舊通知總在新執行的通知出現前 4.7–10 s 就關了。
- **經 `POST /soft-stop` 或看門狗的 Stop，agent 拿到的是 `EXECUTION_UNCONFIRMED_NO_RETRY`**，不是 `STOPPED_NO_RETRY`；執行回執在 `stopReportedBy` 裡寫明來源。重新提交之前，先看 `/status` 的 `resetGeneration` 和執行回執。`STOPPED_NO_RETRY` 已在 Windows 的 `d020b036` 上（11-06）用 Terminal 的 Stop 按鈕核過。
- **Stata 報錯的回傳碼按保守條件確認；Windows 上只實機測了 agent 路徑。** 只有同時滿足這些條件才算確認：這次執行沒被取消（Stop、watchdog、Break、rc 1），紀錄是這次執行自己的，最後一行 `r(n)` 後面只有回顯的命令，完成 marker 沒有列印出來，回傳碼是正整數且等於 mcp-stata 給的 rc。mcp-stata 只有打了執行環境補丁（PR #28）才在 `task_done` 裡帶這個 rc，取自本次執行已經拿到的響應；沒打補丁的執行環境不帶 rc，報錯一律確認不了。其他情況 Terminal 路徑仍是 rc -1，agent 仍拿到 `EXECUTION_UNCONFIRMED_NO_RETRY`；報錯文字裡提到 cancel、timeout 或 stall 的也不確認。macOS 建置版本 `b82203d`（11-05）：agent 交的 `display nosuchvar` 回傳 `STATA_ERROR_CONFIRMED`、`stataRc` 111，下一條命令 rc 0；人輸入同一條報錯命令，執行以 rc 111 結束，下一條命令 rc 0；工作階段一直可用。這個建置版本不是現在的 `main`；同樣的檢查在 `d5b03df` 上（11-06）也通過了。Windows（`d020b036`，11-06）：agent 交的 `display nosuchvar` 回傳 `STATA_ERROR_CONFIRMED`、`stataRc` 111，下一條命令 rc 0；Stata 紀錄裡有 `r(111);`，擴充套件紀錄裡沒有報錯文字。人在 Windows 上輸入的報錯命令沒測。離線跨模組測試裡的 `task_done` 結果是手工構造的，介面部分是樁，所以它不是 MCP 傳輸測試，也不是端到端測試。
- **通用的紀錄解析器只認普通寫法 `r(n);`**，不認 mcp-stata 1.26.1 寫的 SMCL 寫法 `{search r(111), local:r(111);}`，只有新的報錯檢查兩種都認。報錯沒被確認時，release 時推斷的 rc、Run File 的收尾和 watchdog 的報錯檢查在這類紀錄裡仍然看不到 rc。
- **Terminal 裡能看到包裝行。** RESULT 頁會顯示每條命令前後加的行，比如 `display as text "___CODEX_RUN_DONE_…___"`、第二個 `r(111);` 和 `scalar _wb_rc_… = _rc`；agent 卡片的命令列裡還能看到用戶端的核驗 marker。它們來自擴充套件和 mcp-stata 執行環境對命令的包裝。完成檢查和一次執行的紀錄證據都依賴這層包裝，所以暫時沒有隱藏。
- **重開的工作階段可能換連接埠。** 剛 `close` 完，舊連接埠可能還處於 TIME_WAIT，啟動器就換下一個空閒連接埠。工具按工作階段名找工作階段。
- **Windows 派發開銷。** 在 Windows 上，每次 agent 提交比 Stata 本身的工作多花約 15 s（派發前檢查和執行回執核驗）；一條短命令從頭到尾要 17.4 s。20 輪 8 s 命令裡，每次提交的固定開銷是 12–18 s。
- **啟動服務可能要等 PyPI。** 擴充套件在啟動 Stata 服務之前，會先去 PyPI 查一次 `mcp-stata` 的版本。在這個請求會超時的機器上，超時時間會算進第一次啟動。
- **記憶體。** 每個工作階段都是完整的一份 VS Code 加 Stata。macOS 上 5 個工作階段 RSS 合計 3852–4000 MB（每個 718–850 MB）。在 16.8 GB 記憶體的 Windows 機器上，兩個空閒工作階段的工作集分別是 1.93 GB 和 2.16 GB，有負載時每個 2.00–2.39 GB。這種設定的機器開第三個工作階段前，先看可用記憶體。
- **工作區信任。** 新工作區要點一次 **Trust**，擴充套件才會啟動。
- **agent 宿主。** Codex 沒有針對 `.do` 檔案的按檔案 deny 規則，見[agent 改 Stata 檔案要經人審閱](#agent-改-stata-檔案要經人審閱)。
- **繼承自穩定版的：** 多行選區裡頂層的 `exit` 會結束整個選區，並被報成失敗；Data Browser 的 frame 名只在開啟瀏覽器時更新；只用 `graph use` 不會在 Terminal 裡生成圖卡片；不保證顯示的原始碼和實際執行的位元組完全一致。
- 維護的是 `dist/extension.js` 這個 bundle。另有一套參考原始碼建置，但它和 bundle 的功能是否一致沒有確認。

</details>

## 平台實測結果

**僅供歷史證據參考。** 以下為原 Next 測試結果，不是 0.2.0 候選版、一般視窗，
或實際人與 agent 宿主互動的驗收結果。保留原建置雜湊及限制，不重新標記為新版通過。

<details>
<summary>原 Next 平台測試紀錄</summary>

所有實機測試都用隔離的 Next 設定目錄、合成的 `.do` 檔案和 `17601`–`17620` 連接埠，沒有用到研究資料。
介面操作（Stop、Trust、KILL）透過 VS Code DevTools 協議驅動，不是真人按鍵。日期為 2026 年、臺北時間。
建置版本指 `main` 的提交：`e7e54848`、`579b0fe9` 和 `171138b6` 都是 `0.2.0-next.5`，`8d63cb45` 是 `0.2.0-next.4`。

11-04 的各行來自兩類建置版本。`aba81779` 是 `v0.2.0-next.5` 釋出版。`a1a2832b`（PR #21）、`40abcbea`（PR #20）
和 `2ec968a`（PR #24）是 PR 的 head，在複核返工和合併之前測的。之後 macOS 在 `main` `b0bc49d` 上做了實機複驗，
Stata 報錯回傳碼和 KILL 後遺留的 worker 另在 `b82203d` 上測過。
PR #30 在它的最終 head `8739778` 上做了實機檢查，這個 head 的檔案樹和合併提交 `e0b4e11` 相同。PR #31 在最後一輪複核返工之前，於 macOS 的 head `db105f28` 和 `4a1ac2e` 上做過實機檢查，見[已知限制](#已知限制)。

<!-- FMAC-RESULT -->
11-06 對合併後的執行環境做了實機複驗：macOS 用 `d5b03df`（PR #31 的合併候選；擴充套件 bundle 和清理核心與 `main` `d020b036` 相同，只有 Python 的 `close` 工具不同），Windows 用 `main` `d020b036`（16 項裡 15 項通過）。這幾輪發現了由 PR #32 和 PR #33 修復的兩個 macOS 缺陷，以及下面的 Windows KILL 恢復缺陷。PR #33 的最後一個提交 `32ff282`（恢復步驟前後的停止檢查）只有離線測試。在釋出提交上做過的檢查列在它的 GitHub 釋出說明裡。
<!-- /FMAC-RESULT -->

<!-- KW-RESULT -->
這幾輪發現的 Windows KILL 恢復缺陷已由 PR #34（rc.7.90）修復。11-07 在 `main` `80e01c8`（#34 的合併提交）上對 Windows 做了實機複驗：兩個活工作階段中對一個點 **Stata: KILL**，只結束了這個視窗的後端行程樹，這個視窗自己恢復（恢復 smoke 通過，下一條命令 rc 0），另一個視窗的行程不變，下一條命令 rc 0。
<!-- /KW-RESULT -->

### macOS（Apple Silicon，macOS 26.5，StataNow，VS Code 1.139.1）

| 檢查 | 建置版本、日期 | 結果 |
| --- | --- | --- |
| 人和 agent 共用一個工作階段（global、變數、估計結果、圖；Terminal 卡片顯示 agent 名和執行回執裡的 runId） | `8d63cb45`，11-01 | 通過 |
| 同時執行 2、3、5 個工作階段 | `8d63cb45`，11-01 | 通過。5 個工作階段重疊 28.57 s，各自讀回自己的 owner、N 和係數；第 6 個 `open` 回傳 `SESSION_LIMIT` |
| 登錄檔與身分校驗的拒絕（陳舊紀錄、PID 被複用、token 錯、generation 不符、多個活工作階段不帶 `--session`） | `8d63cb45`，11-01 | 通過，7/7 被拒且沒有執行 |
| 兩個 agent 同時往兩個工作階段提交（30 s 命令，間隔 0.008 s 發出） | `579b0fe9`，11-02 | 通過。兩邊都是 HTTP 200，分別用時 34.41 s 和 34.26 s |
| 一個工作階段跑 60 s，另一個工作階段交短命令 | `579b0fe9`，11-02 | 通過。長命令還在跑時，短命令 4.50 s 就回傳了 |
| 兩個工作階段都在忙時只 Stop 其中一個 | `579b0fe9`，11-02 | 通過。被停的工作階段恢復就緒；另一個照常跑完，重置代數不變 |
| 兩個活工作階段時不帶 `--session` | `579b0fe9`，11-02 | 通過。`MULTIPLE_SESSIONS`，什麼都沒執行 |
| 兩個工作階段關掉一個 | `579b0fe9`，11-02 | 通過。它的登錄檔紀錄已刪除；另一個工作階段照常能跑程式碼 |
| 人的長命令在 Terminal 裡按 Stop，兩次 | `579b0fe9`，11-02 | 通過。兩次都是第一次點選就停，Stata 行程不變，資料保留 |
| 對 agent 執行按 Stop | `579b0fe9`，11-02 | 通過。沒有強制重置，執行前狀態已恢復（`RECOVERED_FULL`） |
| 執行前檢查點被刪掉後按 Stop | `579b0fe9`，11-02 | 通過。工作階段鎖住（`trueReady: false`，下一次執行 423，狀態列 STALE） |
| **Stata: KILL** 解鎖 | `579b0fe9`，11-02 | 通過。確認一次，恢復 smoke rc 0，下一次執行成功 |
| 開窗後第一條命令，`loadStataOnStartup` 為 `false`（5 次）和 `true`（2 次） | `aba81779`，11-04 | 通過，7/7 HTTP 200、rc 0，沒有在首條紀錄前卡住。命令先等 Stata 載入完（`false` 11–14 s，`true` 約 7 s，第一次冷啟動 61 s），Output 紀錄先寫「Waiting for Stata to finish loading…」，再寫「finished loading after N s」 |
| Stata 還在載入時交的命令：按 Stop、超時、worker 失敗 | `aba81779`，11-04 | 通過。等待中按 Stop：HTTP 409 `PRE_RUN_BACKEND_WARMUP_CANCELLED`，什麼都沒發出，下一條 rc 0。worker 被凍結：336.5 s 後 HTTP 504 `PRE_RUN_BACKEND_WARMUP_TIMEOUT`，工作階段沒鎖。隨後結束該 worker：HTTP 500 `PRE_RUN_BACKEND_WARMUP_FAILED`；下一條命令等了 37 s 重新載入，回傳 rc 0 |
| 後端 connect 完成之前按 Stop | `aba81779`，11-04 | 失敗。什麼都沒發出，但軟 Stop 35.6 s 後回傳 500，工作階段被鎖（`soft-stop-did-not-restore-checkpoint`）。在這個建置版本上失敗。rc.7.83（PR #25）已修；在 `main` `b0bc49d` 上實機通過（connect 前按 Stop，命令被拒、工作階段沒鎖，下一條命令 rc 0） |
| 命令執行時點 Terminal 的 Stop 按鈕 | `aba81779`，11-04 | 第一輪 0/2：測試驅動點的位置被 Welcome 頁的透明遮罩蓋住，點選沒有到達 Terminal。關掉 Welcome 之後，滑鼠點選、在 Terminal 檢視內點選、**Stata: Cancel Current Request** 各一次都停下了執行，工作階段沒鎖 |
| 人和 agent 輪流跑；agent 執行中人插話 | `aba81779`，11-04 | 通過。人的提交得到 HTTP 409 `bridge busy`，寫明正在執行的 agent；之後雙方讀到同一個 owner、N 和係數 |
| 兩個活工作階段時點 **Stata: KILL** | `aba81779`，11-04 | 通過。只有被鎖工作階段的 3 個行程被換掉；另一個工作階段正在跑的 40 s 命令照常 rc 0 完成 |
| 5 個活工作階段，3 個同時提交 | `aba81779`，11-04 | 部分通過。第 6 個 `open` 得到 `SESSION_LIMIT`。3 個同時提交裡 2 個通過；一個在視窗報就緒約 20 s 後交的 agent 提交，因為後端還沒起來，在派發前被拒（`BLOCKED_NO_DISPATCH`）。在這個建置版本上失敗。rc.7.86（PR #26）已修；在 `main` `b0bc49d` 上實機通過（開窗後立即交的 agent 命令 rc 0，與 `lastCold.runId` 一致） |
| 高負載下（load average 120–140）不輸出的長命令 | `aba81779`，11-04 | 失敗。一條 `bootstrap … dots(50)` 60 s 沒有新紀錄，63 s 時被當作 `EXEC_PRELOG_STALL (IDLE)` 取消，工作階段被鎖。rc.7.84（PR #24）加了 worker CPU 訊號 |
| worker CPU 訊號：空閒噪聲和真卡死 | `2ec968a`，11-04 | 通過。空閒 worker 的 CPU 時間每 12 s 增長 10 ms（閾值 200 ms）。用 SIGSTOP 凍結的 worker 照樣被取消，凍結後 69.7 s；KILL 之後下一條命令 rc 0。不輸出的長命令那一項在首條紀錄預算內就結束了，所以「60 s 空閒且有 CPU 進展」那條路徑還沒有實機測到 |
| agent 交的命令 Stata 報錯（`display nosuchvar`） | `b82203d`，11-05 | 通過。`STATA_ERROR_CONFIRMED`，`stataRc` 111，各項報錯檢查都為真；Terminal 卡片顯示 RC 111。下一條 agent 命令 rc 0，工作階段保持就緒 |
| 人在 Terminal 裡輸入的命令 Stata 報錯 | `b82203d`，11-05 | 通過。執行以失敗結束、rc 111，面板顯示 `RC 111` 和 `r(111);`。下一條輸入的命令 rc 0，之後 agent 命令 rc 0 |
| 人跑 Run File 時點通知裡的 **Cancel**（「Running long_dots.do [Cancel]」） | `8739778`（PR #30），11-05 | 通過。這次點選經和 Terminal 按鈕同一個 Stop 停下了執行；5 s 後工作階段空閒，執行前的狀態已恢復，之後在面板裡輸入的命令 rc 0 |
| 人用 Terminal Stop 停 agent 的執行 | `8739778`（PR #30），11-05 | 通過。agent 拿到 `STOPPED_NO_RETRY`，`stoppedBy` 為 person，各項 stop 檢查都為真；只發了一次請求，沒有重試。下一條 agent 命令通過 |
| 打包、`verify_release` 和裝好的 bundle | `d5b03df`，11-06 | 通過。VSIX 裡的 bundle 和裝好的 bundle 都等於固定的 SHA-256；`verify_release --vsix` 116/116；執行環境清單的 115 個檔案與裝好的副本一致 |
| 開窗後第一條命令，`true` 和 `false` 各兩次；等待中按 Stop | `d5b03df`，11-06 | 通過，4/4，面板和紀錄裡都有等待提示。等待中 Stop（經 `/soft-stop`）以 `PRE_RUN_BACKEND_WARMUP_CANCELLED` 被拒，什麼都沒發出，下一條命令 rc 0 |
| Run File 通知裡的 **Cancel**；人用 Terminal Stop 停 agent 的執行 | `d5b03df`，11-06 | 通過。Cancel 停下了執行，執行前狀態已恢復，之後輸入的命令 rc 0。agent 拿到 `STOPPED_NO_RETRY`（一次請求、沒有重試，8 項 stop 檢查都為真） |
| 新執行進行中點舊通知的 **Cancel** | `d5b03df`，11-06 | 沒做到。3 次嘗試裡，舊通知都在新執行的通知出現前 4.7–10 s 關掉了；新執行每次都 rc 0。只有離線測試 |
| agent 和人各交一條報錯命令 | `d5b03df`，11-06 | 通過。agent：`STATA_ERROR_CONFIRMED`、`stataRc` 111，下一條 agent 命令 rc 0。人：rc 111，下一條輸入的命令 rc 0 |
| 四個活工作階段：輪流、報錯命令、Stop、對其中一個點 KILL | `d5b03df`，11-06 | 通過。KILL 只換掉了那個工作階段自己的三個行程；另一個工作階段 40 s 的迴圈以 rc 0 跑完。人跑 Run File 時用滑鼠點面板的 Stop，仍點在通知上；通知裡的 Cancel 能停下執行 |
| 不輸出的命令執行中點 KILL（孤兒 worker） | `d5b03df`，11-06 | 通過。舊 worker 和它的 resource tracker 被結束；同一資料夾裡一個命令列像 worker 的測試行程 pid 和啟動時刻都沒變 |
| 不輸出的 `bootstrap … reps(400) nodots`；`/status.watchdogCpu` | `d5b03df`，11-06 | 通過。105 s 沒有輸出，108 s 以 rc 0 完成，有 CPU 進展（8 次取樣裡 7 次，0 次出錯）；22 次輪詢都有 `watchdogCpu` |
| 本視窗的 worker 被 SIGSTOP 停住時的強制重置 | `d5b03df`、`d020b036`，11-06 | 失敗，4/4。強制重置結束服務行程約 1 s 後，擴充套件宿主退出（code 0），只剩 VS Code 主行程，`close` 回傳 `CLOSE_PENDING`。`e0b4e11`（#31 之前）上沒有出現。由 PR #33 修復 |
| 在 PR #33 的第一個 head 上做同樣的對照 | `3c8e4f3`，11-06 | 通過，2/2。發任何終止訊號之前 worker 先被恢復，擴充套件宿主活了下來；**Stata: KILL** 解鎖了工作階段，下一條命令 rc 0，`close` 回傳 `CLOSED`。其中一次有一行 `host-group-unknown`（什麼都沒發；原因沒查到） |
| 還有行程佔著 workspace 時的 `close` | `d5b03df`、`d020b036`，11-06 | `d5b03df` 上失敗：每次 `lsof +d` 都以退出碼 1 帶行回傳，`close` 報 `identity-unreadable` 和 `holders: unknown`。用 #32 的 `close` 工具（`main` `d020b036`）通過：一個佔著 workspace 的活測試行程被列為 unresolved（`holders: present:1`、`clean: false`、什麼訊號都沒發）。比視窗活得更久的真實 Stata worker 沒有造出來 |

### Windows（Windows 11 x64，Stata 18 MP，VS Code 1.144.0）

| 檢查 | 建置版本、日期 | 結果 |
| --- | --- | --- |
| 新設定目錄關閉 VS Code 和擴充套件的自動更新 | `171138b6`，11-02 | 通過 |
| agent 改稿審閱：接受、拒絕、審閱期間被改 | `171138b6`，11-02 | 通過 |
| 拒絕：PID 被複用、token 錯、連接埠被佔、陳舊紀錄 | `171138b6`，11-02 | 通過，什麼都沒發 |
| 雙工作階段：兩個 agent 同時提交、一邊忙一邊提交、Stop 其中一個、互不串、`MULTIPLE_SESSIONS` | `579b0fe9`，11-02 | 通過。兩次執行重疊 40.5 s；讀回分別是 `owner=w3a N=111` 和 `owner=w3b N=222` |
| 雙工作階段 20 輪同時提交（40 次執行，其中 5 次中途 Stop） | `e7e54848`，11-03 | 通過，20/20。沒被 Stop 的 35 次全部通過，紀錄沒有一行串到另一個工作階段；被 Stop 的 5 次都恢復了、沒有強制重置，另一個工作階段的重置代數不變（5/5）。20 輪裡 Stata pid 都沒變 |
| 人的長命令在 Terminal 裡按 Stop，五次 | `e7e54848`，11-03 | 通過，5/5。第一次點選就停，Stata 行程不變，Stop 之前的資料保留 |
| 執行前檢查點被改名後按 Stop | `e7e54848`，11-03 | 通過。提示寫明沒有恢復執行前狀態、工作階段已鎖、要點 **Stata: KILL**；狀態 fenced，下一次執行 423。`579b0fe9` 上同一場景的提示錯說檢查點已恢復 |
| 人的長命令在 Terminal 裡按 Stop，兩次 | `579b0fe9`，11-02 | 通過，2/2：第一次點選就停，Stata 行程不變，資料保留 |
| 從 Terminal 停掉 agent 執行 | `579b0fe9`，11-02 | 通過。執行前檢查點已恢復（`restored=true`），讀回 N=77 |
| 執行前檢查點被移走後按 Stop | `579b0fe9`，11-02 | 通過。工作階段鎖住（`snapshot-expected-not-restored`） |
| 看門狗取消一條靜默的 agent 命令 | `579b0fe9`，11-02 | 部分通過。執行前檢查點已恢復，但取消升級成了強制重置，狀態裡報的是上一次失敗的原因 |
| 看門狗取消一條靜默的 Terminal 命令 | `e7e54848`，11-03 | 通過。靜默探針讀到了自己的 marker，沒有強制重置；鎖定原因是這次取消自己的（`elapsedMs 63187`、`stallReason IDLE`） |
| 開窗後的第一條命令，`loadStataOnStartup=false` | `579b0fe9`，11-02；`e7e54848`，11-03 | 時好時壞：3 次卡了 2 次（約 120 s 後 HTTP 504，工作階段鎖住）；另一次 42.2 s 回傳 rc 0。`e7e54848` 上的 504 報 `EXEC_OUTCOME_UNKNOWN`、`payloadMayHaveRun: true` |
| 開窗後的第一條命令，`loadStataOnStartup=true` | `579b0fe9`，11-02 | 通過。開窗時 Stata 在背景載入，用了 57.7 s；之後第一條命令 6.1 s 完成，rc 0 |
| 預設 `loadStataOnStartup`（設定裡沒有這個鍵），開窗後第一條 agent 命令 | `3765d82a`，11-03 | 通過，3/3。啟動器寫入 `true`；`open` 之後 106.6–107.7 s Stata 就緒；第一條 agent 命令 23.1–25.2 s 回傳 rc 0。`open` 之前寫好的 `false` 被保留 |
| agent 路徑和 Terminal 路徑上的看門狗取消 | `3765d82a`，11-03 | 通過。每次取消都在 `/status.lastGuardFailure` 記下自己的 `runId` 和 `elapsedMs`（63 615 ms 和 63 159 ms）；鎖定原因 `EXEC_PRELOG_STALL (IDLE)`。只出現了 `IDLE` 這一種停頓 |
| 被取消的冷啟動命令的遲到事件（`loadStataOnStartup=false`） | `3765d82a`，11-03 | 通過。命令 167.1 s 後回傳 HTTP 504；它遲到的 `log_path` 事件以 `not this client's run` 被丟棄，沒有交給下一次執行 |
| 這類取消之後的普通命令；重新開窗後的第一條 Terminal 命令 | `3765d82a`，11-03 | 部分通過。解鎖後同一後端：5/5 rc 0，每條約 3.1 s，紀錄裡沒有別人的行。預設 `true` 重新開窗：0/2。`connect` 完成（54.2 s）後立刻發的第一條 Terminal 命令在首條紀錄前卡住，163.9 s 後回傳 HTTP 504；工作階段被鎖，第二條得 423 |
| 兩個工作階段，8 輪同時提交 agent 命令、其中 2 輪按 Stop；Terminal Stop 3 次 | `3765d82a`，11-03 | 通過。沒被停的 14/14 全部通過；被停的 2 次都恢復了，沒有強制重置；紀錄沒有串到另一個工作階段；每輪 21.4–24.8 s。Terminal Stop 3/3 第一次點選就停 |
| `close` 清理殘留的臨時登錄檔 | `171138b6`，11-02；`e7e54848`，11-03 | `171138b6` 上部分通過（漏了一個檔案）。`e7e54848` 上通過：寫入行程已退出的檔案被刪，登錄檔為空。「行程已退出卻報錯誤碼 5」這種情況沒出現（三個都報 87），那一支只有單元測試 |
| 跳過恢復 smoke 時的 KILL 提示；遲到事件後探針讀自己的紀錄 | `e7e54848`，11-03 | 部分通過。前者在 Windows 上走不到（那裡 KILL 一定會跑 smoke）；後者需要的遲到事件在兩次懶載入裡都沒重現。兩支都只有單元測試 |
| 新開窗、`connect` 剛完成就發的第一條 Terminal 命令 | `e5d2cda7`，11-04 | 通過，3/3。HTTP 200、rc 0，3.05–3.12 s 回傳；第二條也通過。派發前擴充套件先查了 worker 狀態（`list_sessions` 4–6 ms；worker 已在 running，所以沒有出現等待提示）。同一檢查在 `3765d82a` 上也 2/2 通過，所以這次複驗不能說明之前那次卡住已經消除 |
| 開窗後第一條 agent 命令；4 次 agent 執行、最後一次軟 Stop；Terminal Stop | `e5d2cda7`，11-04 | 通過。第一條 agent 命令 11.5 s 回傳 rc 0。第 1–3 次 14.4–15.7 s 通過；被停的那次恢復了檢查點（`restored=true`，沒有強制重置），Stop 之前的資料保留。Terminal Stop 第一次點選就停，Stata 行程不變 |
| 開窗後第一條 Terminal 命令，帶分段計時（`loadStataOnStartup` 為 `true` 和 `false`，新建和複用的設定目錄） | `a1a2832b`，11-04 | 通過，24/24 HTTP 200、rc 0，其中 10 次用的是新建設定目錄。每條第一條命令都先等 Stata 載入 16–60 s，之後執行、log path 和首行輸出在 0.6 s 內跟上。帶同樣計時行的舊建置版本 `3765d82a` 17 次裡卡了 1 次（約 120 s 後 HTTP 504）；見[已知限制](#已知限制) |
| 4 條 8 s 命令，第 2 條軟 Stop；點一次 Terminal 的 Stop 按鈕 | `a1a2832b`，11-04 | 通過。Stop 1.65 s 回傳，檢查點已恢復，沒有強制重置；另外 3 輪的開始和結束行都寫進了紀錄；Stata 行程不變。Terminal Stop 第一次點選就停。面板剛拿到焦點時的第一次 Run 點選沒有反應，和之前的 Windows 測試一樣 |
| Stata 還在載入時交的命令（worker 被掛起）：按 Stop、超時、重啟 | `40abcbea`，11-04 | 通過。等待中按 Stop：以 `PRE_RUN_BACKEND_WARMUP_CANCELLED` 被拒，Stata 紀錄裡什麼都沒有。超時：300.1 s 後 HTTP 504 `PRE_RUN_BACKEND_WARMUP_TIMEOUT`，什麼都沒發出。恢復後下一條命令 46.1 s 回傳 rc 0；它的 worker 在啟動中失敗過，被重啟一次、43 s 載入完，命令只執行了一次。沒有出現使用者可見的 `PRE_RUN_BACKEND_WARMUP_FAILED`（`stataPath` 寫錯時 Stata 照樣載入了）。等待提示出現在 Output 紀錄裡；測試用的輸入方式不畫 Terminal 面板，所以 Windows 上面板裡的文字還沒核實 |
| 兩個活工作階段時的 `/panic-kill?dryRun=1` | `d020b036`，11-06 | 通過，2/2。每個視窗只選中自己的 4 個行程，兩組不相交 |
| 兩個活工作階段中對一個點 **Stata: KILL** | `d020b036`，11-06 | 範圍通過，恢復失敗。只有被 KILL 的視窗的行程樹結束；另一個視窗的 pid 不變，下一條命令 rc 0。被 KILL 的視窗恢復 smoke 失敗（`transport-failed`），下一條命令得到 HTTP 423 `panic-kill-command-needs-smoke`；見本節開頭的說明 |
| PR #34 之後，兩個活工作階段中對一個點 **Stata: KILL** | `80e01c8`，11-07 | 通過。只有被 KILL 的視窗的行程樹結束（「ended 3 of 4 … already exited 1」）；點選後 77 s，被 KILL 的視窗顯示「the verified recovery smoke passed; the session is READY」，換了新後端（`resetGeneration` 1），沒關視窗，下一條命令 rc 0。另一個視窗的 pid 不變，下一條命令 rc 0 |
| KILL 恢復之後：Stata 報錯，再由人按 Terminal Stop | `80e01c8`，11-07 | 通過。恢復後的視窗上 `display nosuchvar` 得到 `STATA_ERROR_CONFIRMED`，`stataRc` 111，下一條命令 rc 0。另一個視窗上人按 Terminal Stop 停 agent 的執行，得到 `STOPPED_NO_RETRY`，下一條命令 rc 0；兩個視窗都以 `CLOSED` 關閉 |
| agent 交的報錯命令（`display nosuchvar`） | `d020b036`，11-06 | 通過。`STATA_ERROR_CONFIRMED`、`stataRc` 111，12 項報錯檢查都為真，下一條命令 rc 0。Stata 紀錄裡有 `r(111);`；擴充套件紀錄裡沒有報錯文字 |
| 不輸出的長命令（`bootstrap … reps(400) nodots`，沒有紀錄輸出） | `d020b036`，11-06 | 通過。跑了 192.8 s，rc 0，沒有被取消；15 次取樣裡 14 次有 CPU 進展，0 次出錯；`/status.watchdogCpu` 存在 |
| 後端被凍住時交的命令：失敗、按 Stop | `d020b036`，11-06 | 通過。失敗：51 s 後面板顯示 `PRE_RUN_BACKEND_WARMUP_FAILED`，什麼都沒發出，下一條命令 rc 0。身分探針期間按 Stop：HTTP 409 `PRE_RUN_BACKEND_WARMUP_CANCELLED`，什麼都沒發出；`/soft-stop` 呼叫本身用了 58 s，工作階段一直鎖著（見已知限制） |
| 第一條命令；真實 Terminal 面板裡的等待提示 | `d020b036`，11-06 | 通過。`loadStataOnStartup` 為 `true` 和 `false` 時，開窗後馬上交的 agent 命令都通過；`false` 時第一條 Terminal 命令 73.4 s 回傳 rc 0。面板從 4.7 s 到 42.7 s 顯示「Waiting for Stata to finish loading」，之後顯示輸出 |
| 人用 Terminal Stop 停 agent 的執行；`close` | `d020b036`，11-06 | 通過。`STOPPED_NO_RETRY`，`stoppedBy` 為 person，各項 stop 檢查都為真，下一條命令 rc 0。6 次 `close` 都回傳 `CLOSED` |

macOS Intel 和 Windows Server 2022 在每個 PR 的 CI 上跑離線測試和打包（沒有授權的 Stata）。
Windows 10、Windows on ARM 和 Linux 未驗證。

PR #15（Stop/KILL 提示與實際結果一致、Windows 行程存活判定、靜默探針修復）已在 Windows 上用 `e7e54848` 實機複驗
（表中 11-03 各行）。PR #17（`e9b22430`：開窗即載入 Stata、看門狗取消寫明自己的停頓、遲到事件跟著自己的任務走）
已在 Windows 上用它的 head `3765d82a`（bundle 與 `e9b22430` 相同；表中標 `3765d82a` 的各行）實機複驗。三項修復都成立，但 Stata 剛載入完就發的 Terminal 命令卡過一次。PR #18（`1bf02d02`：Terminal 命令派發前先等 Stata warm-up）
已在 Windows 上用它的 head `e5d2cda7`（原始碼樹相同；表中 11-04 各行）實機複驗，見[已知限制](#已知限制)。macOS 在 11-04 用 `v0.2.0-next.5` 釋出版（`aba81779`）做了實機複驗，
11-04 至 11-05 又在 `main` `b0bc49d`（PR #19–#21、#23–#26 之後，#27、#28、#22 之前）上複驗了一次，發現的問題列在[已知限制](#已知限制)。
11-06 macOS 在 `d5b03df` 上、Windows 在 `main` `d020b036` 上複驗（表中 11-06 各行）；11-07 在 PR #34 之後的 `main` `80e01c8` 上複驗了 Windows（表中 11-07 各行）。

</details>

## 開發

文件檢查使用 `git diff --check`、本機連結檢查與 CLI 解析器檢查。
執行環境整合另外需要下列釋出檢查；建置只能在本機或 CI 執行，不能在正式環境／VPS 伺服器執行。

```sh
npm ci --ignore-scripts
npm run check -- --keep-going
python3 -B -m unittest discover -s tools -p 'test_*.py'
npm run package
python3 -B tools/verify_release.py --packaged
```

套件名稱為 `stata-workbench-shared-session-<version>.vsix`。以上是驗證命令，不代表候選版已通過。
釋出負責人須重新產生 bundle 身分與執行環境清單，檢查確切 VSIX，並另外記錄已授權機器的實測證據。
見 [CONTRIBUTING.md](CONTRIBUTING.md)、[釋出維護](docs/RELEASE.md)與 [CHANGELOG.md](CHANGELOG.md)。
Next 歷史操作文件保留原來的適用範圍；一般視窗候選版請使用本 README 與[日常流程](docs/agent-daily-workflow.md)。

## 授權條款

AGPL-3.0-or-later。派生自 [tmonk/stata-workbench](https://github.com/tmonk/stata-workbench)。
與 [hanlulong/stata-mcp](https://github.com/hanlulong/stata-mcp) 的設計比較在 [NOTICE](NOTICE) 裡致謝，
這並不表示兩者的執行環境可以互換。見 [LICENSE](LICENSE) 和 [SECURITY.md](SECURITY.md)。

不包含 Stata、Stata 授權、憑據或資料。bridge 只監聽 `127.0.0.1`，不是遠端服務，也不是多使用者服務。
