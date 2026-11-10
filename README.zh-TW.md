# Stata Workbench Shared Session

<img src="media/icon.png" alt="Stata Workbench Shared Session 標誌" width="96">

[English](README.md) | [简体中文](README.zh-CN.md) | 繁體中文

這是一個 VS Code 擴充套件：人和 AI agent 輪流使用同一個可見的 Stata 工作階段。雙方的程式碼
都送到同一個 backend，所以資料、巨集、scalar、結果和圖形是共享的。

## 這是什麼

- 編輯器裡：**Run Current File**、**Run Selection/Current Line**、Stata Terminal、
  Stata Graphs 面板和 Data Browser。
- 給 agent 用：`tools/shared_stata.py` 經本機 HTTP bridge 向正在執行的工作階段傳送一條
  命令或一個已儲存的 `.do` 檔案，並寫一份私有回執。
- 同一個 backend 的提交逐個執行。人和 agent 輪流操作；自動執行進行中時不要在編輯器裡輸入。
- 共享記憶體不是持久儲存。重置、重啟或關閉 VS Code 之前，把資料和結果存到磁碟。
- 不包含 Stata、Stata 授權、憑證或資料。bridge 只監聽本機 loopback 位址，不是遠端或多使用者服務。

派生自 [tmonk/stata-workbench](https://github.com/tmonk/stata-workbench)
（AGPL-3.0-or-later），見[授權條款](#授權條款)。

### 版本

| 版本 | 狀態 | 平台證據 |
| --- | --- | --- |
| [`v0.1.3-rc.7.45`](https://github.com/lzhs1995/stata-workbench-shared-session/releases/tag/v0.1.3-rc.7.45) | 最新 pre-release（2026-10-31） | macOS 和 Windows，見[平台狀態](#平台狀態) |
| [`v0.1.3-rc.7.44`](https://github.com/lzhs1995/stata-workbench-shared-session/releases/tag/v0.1.3-rc.7.44) | 更早的 pre-release（2026-10-30） | macOS 和 Windows |
| [`v0.1.3-rc.7.39-public.2`](https://github.com/lzhs1995/stata-workbench-shared-session/releases/tag/v0.1.3-rc.7.39-public.2) | 更早的 pre-release（2026-09-09） | 僅 macOS |

本文件對應 `v0.1.3-rc.7.45`。每條結果都寫明是在哪個版本上測的；除非另行註明，rc.7.45 的結果
都是在發布的 VSIX（`b371bc61…`）上測的。

### 文件

- 給 agent：[AGENTS.md](AGENTS.md)；操作規則以 [stata-workbench-shared-session-skill](https://github.com/lzhs1995/stata-workbench-shared-session-skill) 為準
- [跨平台開發與設定](docs/CROSS_PLATFORM.md)
- [Windows 實機驗收手冊](docs/WINDOWS_ACCEPTANCE.md)、[早期 Windows 工具的去向](docs/LEGACY_WINDOWS.md)
- [能力與證據清冊](SYNC.md)、[驗收範圍](docs/ACCEPTANCE.md)
- [macOS 權限](docs/MAC_PERMISSIONS.md)、[疑難排解](docs/TROUBLESHOOTING.md)
- [共享執行與並行](docs/shared-execution-and-concurrency.md)
- [共享工作階段交付經驗](docs/shared-session-delivery-lessons.md)、
  [研究交接與歸檔經驗](docs/empirical-review-and-archive.md)
- [發布維護](docs/RELEASE.md)、[變更紀錄](CHANGELOG.md)
- [中文使用指南（簡體中文）](docs/USAGE.zh-CN.md)

## 平台狀態

同一個 VSIX 用於 macOS 和 Windows。候選版在 macOS 和 Windows CI 上打包出的 VSIX，執行階段
檔案逐位元組相同，只有隨附文件的換行字元不同。

| 平台 | 測試環境 | 結果 |
| --- | --- | --- |
| macOS，Apple Silicon | macOS 26.5 arm64、StataNow、VS Code 1.139.1、隔離 profile | 本發布檔案已安裝（身分核對通過）；冷啟動首次執行 200、rc 0。在本檔案上用實體按鍵重跑的 FULL45 場景：S2、S6、S10、S12、S16、S20、S26、S40 每一步都通過；S43 的 9 次 agent 選取範圍執行都是 200、rc 0（唯一的失敗是測試工具從錯誤的目錄讀輸出）。在最後一次修復之前的建置上，S2、S6、S10、S16、S20、S26、S43 都因成功的 agent 執行被答成 HTTP 500 而失敗。S9、S11、S33 每一步都執行了，只在測試工具的證據檢查上失敗（transport 回執；reopen 後恢復原前景應用程式）。S41 與 rc.7.44 一樣失敗（見已知限制）；S34 第一個按鍵沒能發出（測試工具） |
| macOS，Intel | 只有 CI（macOS 15 Intel） | 離線測試與打包；沒有用授權 Stata 實跑 |
| Windows 11 x64 | Windows 11 家庭中文版 24H2（build 26100）、Stata 18 MP、VS Code 1.121.0、Windows PowerShell 5.1、隔離 profile | rc.7.45（發布的 VSIX）：安裝與身分核對；冷啟動首次執行（backend 31.3 秒）；agent `do "<文件>"` 帶紅字和 `exit 0` 3/3 傳回 200、rc 0（上一個建置是 500），force reset 後緊接著跑 3/3 同樣通過；失敗的正文傳回自己的 rc 603 和錯誤訊息；agent 路徑的命名圖形匯出（task5：22 個 PNG、28 個 SVG）；執行前 checkpoint 期間按 Stop 完整恢復。在最後一次修復之前的建置上，程式碼開始執行後按 soft Stop，118 秒恢復了 160 個估計結果和 80 個圖，沒有升級。驗收手冊第 10 步（發布的 VSIX，事後核驗）：使用者鎖定螢幕、解鎖並在 UAC 提示視窗點「否」之後，backend 和擴充套件主機仍是原來的處理程序（reset generation 不變），agent 執行（200、rc 0）、開啟圖形和 Data Browser 都正常。鎖定螢幕在 Winlogon 通知裡有記錄；UAC 點「否」只有使用者口述。 rc.7.44：壓力測試 32/32，三次 Reload Window 冷啟動 |
| Windows，預設安裝路線 | 同一台機器，空的 `uv` 快取 | 帶 `mcp<2` 時服務裝好並能匯入；不帶時 `uv` 解析到 MCP 2.x，服務匯入失敗 |
| Windows Server 2022 x64 | 只有 CI | 離線測試、真實檔案鎖、處理程序比對、PowerShell 5.1/7 入口；沒有授權 Stata |
| Windows 10、Windows on ARM、Linux | — | 未驗證 |

### Windows 測試步驟

來自 [Windows 驗收手冊](docs/WINDOWS_ACCEPTANCE.md)，只用合成資料。第 1–8 步在
dev.5 上通過。第 9 步在 dev.5 上失敗（backend 冷啟動超出 60 秒的執行前預算），修復後
在 dev.6 上通過。第 10 步在 dev.6 上做過，rc.7.45 上又做了一次（在發布的 VSIX 上事後核驗：鎖定螢幕、解鎖、UAC 點「否」之後 backend 和擴充套件主機沒變，agent 執行、開啟圖形和 Data Browser 都通過；UAC 點「否」只有使用者口述）。第 1–8 步
沒有在 dev.6–dev.8 上重跑；rc.7.45 做的是平台狀態裡列出的執行。

| 步驟 | 檢查內容 |
| --- | --- |
| 1 | Run Current File：rc 0，6 行 / 4 個變數，CSV/DTA/GPH 和兩張 800×480 PNG，GPH 可重新載入 |
| 2 | Terminal 裡點圖形縮圖 → **Open**：Stata Graphs 載入圖片，執行計數不變 |
| 3 | Data Browser：6 行 / 4 個變數，Unicode 標籤保留 |
| 4 | agent 用戶端：一次 POST，零重試，共享 scalar 40 → 42 |
| 5 | Run Selection 在同一 backend 上讀到 42 |
| 6 | 第一個用戶端忙時提交第二個：等第一個釋放後才分派，各一次 POST |
| 7 | 執行中點 Stop：任務和傳輸排空，沒有硬重置，backend 不變 |
| 8 | 清理用戶端：每項清理 rc 0，恢復原來的空 `default` frame |
| 9 | Reload Window 後第一次執行，backend 冷啟動 |
| 10 | 閒置時鎖定螢幕/解鎖並取消一次 UAC 提示視窗：backend、擴充套件主機和計數都不變 |

## 系統需求

| 項目 | 需求 |
| --- | --- |
| VS Code | 1.75 或更新（測試版本：macOS 1.139.1，Windows 1.121.0） |
| Stata | 本機已授權的安裝（測試：macOS 上 StataNow，Windows 上 Stata 18 MP） |
| `uv` / `uvx` | 用來啟動 `mcp-stata` 服務（`mcp-stata` 1.26.1，`mcp<2`） |
| Python 3 | 只有 `tools/` 裡的 agent 和診斷工具需要。Windows 上用已安裝的 `python.exe`，不要用 Microsoft Store 的別名 |
| macOS 權限 | 執行 agent 工具的主控程式需要「系統事件」自動化和輔助使用權限，見 [macOS 權限](docs/MAC_PERMISSIONS.md) |

## 安裝

從 [v0.1.3-rc.7.45 發布頁](https://github.com/lzhs1995/stata-workbench-shared-session/releases/tag/v0.1.3-rc.7.45)
下載 `stata-workbench-shared-session-0.1.3-rc.7.45.vsix` 和 `SHA256SUMS`，放在同一個
資料夾。安裝前用 `SHA256SUMS` 核對 VSIX（見[驗證下載檔案](#驗證下載檔案)）；發布說明裡列著同一個雜湊。

下面的命令裝進一個單獨、可識別的 profile，agent 工具按這個 profile 和連接埠找到工作階段。
只在編輯器裡用的話，在平常的 VS Code 裡執行 **Extensions: Install from VSIX...** 就夠了。

### macOS

```sh
export STATA_WORKBENCH_PROFILE="$HOME/.stata-workbench-shared"
export STATA_WORKBENCH_PORT=17485
"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
  --user-data-dir "$STATA_WORKBENCH_PROFILE/user-data" \
  --extensions-dir "$STATA_WORKBENCH_PROFILE/extensions" \
  --install-extension ./stata-workbench-shared-session-0.1.3-rc.7.45.vsix
```

在這個 profile 裡把 `stataMcp.stataPath` 設為已授權的 Stata 執行檔。

### Windows

在 PowerShell 裡：

```powershell
$env:STATA_WORKBENCH_PROFILE = Join-Path $HOME '.stata-workbench-shared'
$env:STATA_WORKBENCH_PORT = '17485'
code --user-data-dir "$env:STATA_WORKBENCH_PROFILE\user-data" `
  --extensions-dir "$env:STATA_WORKBENCH_PROFILE\extensions" `
  --install-extension .\stata-workbench-shared-session-0.1.3-rc.7.45.vsix
```

`code` 就是 VS Code 的 `bin\code.cmd`；不在 `PATH` 裡時見[疑難排解](#疑難排解)。把
`stataMcp.stataPath` 設為已授權的執行檔，例如 `C:\Program Files\Stata18\StataMP-64.exe`。
用 `$env:` 設的變數只在目前 PowerShell 視窗有效。

Windows 上的測試用的是[驗收工具](docs/WINDOWS_ACCEPTANCE.md)建的私有 profile 和 17497
連接埠，不是上面的預設 profile。

### agent 工具

agent 和診斷工具在本存放庫裡，不在 VSIX 裡。按發布 tag clone，工具鎖定的版本才和裝好的
VSIX 一致：

```sh
git clone https://github.com/lzhs1995/stata-workbench-shared-session.git
cd stata-workbench-shared-session
git checkout v0.1.3-rc.7.45
python3 -B tools/verified_workbench.py --doctor
```

Windows 上把 `python3` 換成 `python`。`--doctor` 輸出 JSON（系統與架構、Python、VS Code、
profile 和連接埠、Stata 候選路徑、已安裝和正在執行的身分），不會啟動 VS Code 或 Stata。

## 快速開始

先設好同樣的 `STATA_WORKBENCH_PROFILE` 和 `STATA_WORKBENCH_PORT`：

1. 只在 macOS 上做一次：在將要執行 agent 的主控程式裡執行
   `python3 -B tools/verified_workbench.py --request-permissions`，在系統對話方塊裡允許。
2. 用範例工作區開啟這個 profile：
   `python3 tools/verified_workbench.py --open --workspace "$PWD/examples/minimal-workspace"`。
   `--open` 重複使用同一個 profile，沒有時只啟動一次。
3. 還沒設 `stataMcp.stataPath` 的話現在設。
4. 執行 **Stata: Open Interactive Terminal**，開啟 `smoke.do`，執行
   **Stata: Run Current File**。Terminal 列印 `STATA_WORKBENCH_SMOKE_OK`。

開啟或重新載入後的第一次執行還要啟動 Stata 服務。dev.8 的測試機上分別用了 14.1 秒（macOS）
和 25.2 秒（Windows）。等它跑完，不要重複提交。唯一的例外是 `PRE_RUN_SNAPSHOT_TIMEOUT`
（見[疑難排解](#疑難排解)）：那次執行在程式碼發出之前就被拒絕了，再執行一次是安全的。

### 共享工作階段

在 Stata Terminal 裡執行 `scalar public_shared_demo = 40`，等它就緒。在設了同樣
profile 和連接埠的 shell 裡：

```sh
python3 tools/shared_stata.py --code 'scalar public_shared_demo = public_shared_demo + 2' --cwd "$PWD"
```

回到 Terminal，`display public_shared_demo` 顯示 42。最後執行
`scalar drop public_shared_demo`。這個名字已經被你的工作佔用時換一個。

## 使用

| 要做的事 | 怎麼做 |
| --- | --- |
| 執行整份 `.do` 檔案 | **Stata: Run Current File**（`Ctrl+Shift+D`，macOS `Cmd+Shift+D`） |
| 執行選取內容或目前這一行 | **Stata: Run Selection/Current Line**（`Ctrl+Shift+Enter`，macOS `Cmd+Shift+Enter`） |
| 開啟 Terminal | **Stata: Open Interactive Terminal**（`Ctrl+Shift+C`，macOS `Cmd+Shift+C`） |
| 預覽已儲存的圖 | 在 Terminal 裡點縮圖，再點 **Open**。Stata Graphs 顯示這個檔案，不會再跑一次 Stata |
| 瀏覽資料 | Terminal 裡的 **Data Browser** 按鈕，或 **Stata: View Data** |
| 停止執行 | Terminal 裡的 **Stop** |
| 讓 agent 執行程式碼 | `tools/shared_stata.py`，見下 |

執行快捷鍵在 `.do`、`.ado`、`.mata` 檔案（或 Stata 語言檔案）獲得焦點時生效。

- **圖形。** 點開的預覽會用這一張圖替換目前顯示的這批圖；其他匯出檔案仍可從 Terminal 裡的
  連結和磁碟上找到。沒有開啟 Graphs 面板時，自動出圖的批次讓 Terminal 保持可見。
- **Data Browser。** 顯示行、變數和目前 frame（例如 `wb_platform`）。frame 名在瀏覽器開啟時讀取。
- **Stop。** soft Stop 取消目前執行、排空任務，backend 不變。Terminal 會顯示例如
  `human-file cancelled by soft Stop (generation 1)`，`/status` 報
  `resetGenerationKind: "soft-stop"`。如果 Stop 落在執行還在儲存執行前 checkpoint 的時候，
  執行在你的程式碼開始前就停下：正文不會發出（`payloadDispatched: false`；HTTP 409
  `PRE_RUN_CANCELLED_BY_STOP`，checkpoint 還不完整時是 500 `EXEC_REJECTED`）。下一次執行前先確認工作階段重新就緒。

### agent 用戶端

```sh
python3 tools/shared_stata.py --code 'display 1+1' --cwd /absolute/workspace
python3 tools/shared_stata.py --file analysis.do --cwd /absolute/workspace --busy-policy wait --max-wait 60
```

- 每次呼叫一次 POST，不自動重試。逾時或結果不明不能證明 Stata 沒有執行；再提交前先查回執和工作階段。
- 遇到 bundle 或監聽方不對、重複的啟動器、工作階段忙或在恢復、backend 變了，都會拒絕。
  `--busy-policy wait` 只在提交前等待，最多 `--max-wait` 秒。
- 它從不啟動、啟用、重置或重試 Stata。它需要已經在執行的 backend：開啟或重新載入 VS Code 後，
  先在編輯器或 Terminal 裡執行一次（Run File、Run Selection 或 Terminal 命令都可以）。
- 機器負載很高時唯讀探測逾時（`ps`/`lsof`，以及 macOS 上的被動權限檢查和視窗查詢），會重新觀測，
  總共最多 3 次。權限檢查逾時報 `PERMISSION_CHECK_TIMEOUT`，不當作權限失敗。POST 本身從不重發。
- 結束代碼 0 表示結論 `PASS_VISIBLE_SHARED_RUN`：執行和身分檢查通過；不證明有人同時看著原始碼和
  Terminal。其他結果結束代碼為 2。
- 每次呼叫把請求、回應、實際提交的 `.do` 位元組和執行記錄檔寫進 `.stata-receipts/`
  （或 `--receipt-dir`）。裡面有你的程式碼和輸出，不要提交到存放庫。
- `.do` 路徑可以含中文、空格和撇號；路徑裡有 Stata 巨集分隔符號、雙引號或控制字元會被拒絕。
- Windows 上 `scripts/invoke_stata_visible_safe.ps1` 包裝的是同一個用戶端。它原來的
  `AllowHttp500Retry`、`BusyPolicy reset`、`SmokeAfterReset` 模式現在在分派前就失敗。

## 設定

VS Code 設定：

| 設定 | 預設值 | 說明 |
| --- | --- | --- |
| `stataMcp.stataPath` | 空 | 本機 Stata 執行檔的路徑 |
| `stataMcp.visibleBridgePort` | `17485` | 本機 bridge 連接埠（`/status`、`/run-command`、`/soft-stop`），必須與 `STATA_WORKBENCH_PORT` 相同 |
| `stataMcp.runFileWorkingDirectory` | 空 | Run File 的工作目錄，可用絕對路徑、`~`、`${workspaceFolder}`、`${fileDir}` |
| `stataMcp.loadStataOnStartup` | `false` | VS Code 啟動時啟動 Stata |
| `stataMcp.requestTimeoutMs` | `100000` | 中繼資料和介面請求的逾時 |
| `stataMcp.enableExecuteTimeout` | `false` | 給執行命令設逾時；為長研究腳本預設關閉 |
| `stataMcp.maxOutputLines` | `2000` | Terminal 保留的行數 |
| `stataMcp.autoRevealOutput` | `false` | 執行後顯示輸出通道 |
| `stataMcp.showAllLogsInOutput` | `false` | 把 `mcp-stata` 原始記錄檔全部寫進輸出通道 |
| `stataMcp.logStataCode` | `false` | 記錄發給 backend 的 Stata 程式碼 |
| `stataMcp.autoConfigureMcp` | `false` | 在主控程式的 MCP 設定裡新增或更新 `mcp-stata` |
| `stataMcp.restoreFinalSnapshotAfterGraphRouting` | `false` | Run File 圖形路由後恢復 do 檔案結束時的資料快照 |

工具的環境變數：

| 變數 | 預設值 | 說明 |
| --- | --- | --- |
| `STATA_WORKBENCH_PROFILE` | `~/.stata-workbench-shared` | 隔離 profile 的根目錄 |
| `STATA_WORKBENCH_PORT` | `17485` | 必須與 `stataMcp.visibleBridgePort` 相同 |
| `STATA_WORKBENCH_CODE` | 標準位置的 VS Code | macOS 是 app 的 CLI；Windows 是 `Code.exe`，或會被解析到 `Code.exe` 的 `code.cmd`/`code.bat` |
| `STATA_WORKBENCH_PYTHON` | — | Windows PowerShell 包裝腳本使用的 Python |

連接埠被佔用時工具會拒絕，這不是去關別的編輯器的理由。另選一個未使用的
`stataMcp.visibleBridgePort`，並把 `STATA_WORKBENCH_PORT` 設成同一個值。

## 驗證下載檔案

用同一個發布頁的 `SHA256SUMS` 核對檔案雜湊。

macOS：

```sh
shasum -a 256 -c SHA256SUMS --ignore-missing
```

Windows PowerShell：

```powershell
$f = 'stata-workbench-shared-session-0.1.3-rc.7.45.vsix'
$expected = (Select-String -Path SHA256SUMS -SimpleMatch $f).Line.Split(' ')[0]
(Get-FileHash $f -Algorithm SHA256).Hash.ToLower() -eq $expected
```

最後一行必須輸出 `True`。然後在按發布 tag clone 的存放庫裡，用發布身分清單核對 VSIX 內容：

```sh
python3 tools/verify_release.py --vsix /path/to/stata-workbench-shared-session-0.1.3-rc.7.45.vsix
```

套件版本和每個鎖定的執行階段檔案都一致時，它輸出含 `"verdict": "PASS"` 的 JSON。這只核對執行階段身分，
不是實機驗收。

## 疑難排解

| 現象 | 處理 |
| --- | --- |
| 第一次執行很慢 | 開啟或重新載入後的第一次執行還要啟動 Stata 服務。等它，不要重複提交 |
| 開啟或重新載入後的第一次執行報 `PRE_RUN_SNAPSHOT_TIMEOUT`（HTTP 504） | 機器繁忙時 Stata 啟動超過了 60 秒。這次執行在分派前就被拒絕（`payloadDispatched:false`），你的程式碼沒有執行。再執行一次 |
| Terminal 長時間顯示忙 | 先查 bridge 狀態（`python3 tools/verified_workbench.py --status`）再執行別的程式碼；不要再排一個長任務 |
| 長腳本卡住或逾時 | 先核對原請求、原始記錄檔和輸出。逾時不能證明 Stata 沒有執行。見[儲存與記錄檔恢復](docs/storage-and-log-recovery.md) |
| 連接埠已被佔用 | 別的編輯器佔著。另選未使用的 `stataMcp.visibleBridgePort`，`STATA_WORKBENCH_PORT` 設成同一個值 |
| 狀態列顯示 **Stata: STALE**，執行傳回 HTTP 423 `recovery-required` | force reset 後沒能確認 backend。執行一次經驗證的恢復：`curl -X POST http://127.0.0.1:17485/recovery-smoke`（Windows：`Invoke-WebRequest -UseBasicParsing -Method Post -Uri http://127.0.0.1:17485/recovery-smoke`；連接埠換成你的）。它執行一條固定的標記命令，確認 rc 0 且記錄檔裡有標記後才解鎖。不要強制結束 Stata，也不要刪除工作階段 |
| 圖形不出現 | 給圖命名；多個未命名的圖會互相覆蓋唯一的 `Graph` 視窗 |
| Windows：`code` 裝不上 VSIX | 執行 `Get-Command code` 和 `code --version`；把 `PATH` 改成指向 VS Code 的 `bin\code.cmd`，或用 **Extensions: Install from VSIX...** |
| macOS：錯誤 `-1743` 或找不到視窗 | 在與 agent 相同的主控程式裡執行 `--doctor`，再執行一次 `--request-permissions`。見 [macOS 權限](docs/MAC_PERMISSIONS.md) |
| `No module named 'mcp.server.fastmcp'` | 服務裝成了 MCP 2.x。預設路線會加 `mcp<2`；自訂的服務命令也要加這個約束 |
| `Failed to connect to mcp-stata`，並有 `No solution found when resolving tool dependencies` 和 “the network was disabled” | uv 處在離線模式（例如 `~/.config/uv/uv.toml` 裡的 `offline = true`，或設定了 `UV_OFFLINE`），預設的 `uvx` 路線只能用快取裡已有的套件。第一次啟動時關掉離線模式，讓 `uvx` 把服務下載一次，然後重新載入視窗 |

更多情況見[疑難排解](docs/TROUBLESHOOTING.md)和[桌面恢復記錄](docs/desktop-auth-terminal-recovery.md)。

## 已知限制

- Windows 10、Windows on ARM 和 Linux 未驗證。macOS Intel 只有 CI。
- 授權完整測試集（FULL45）是在 rc.7.45 最後一次修復之前的建置上跑的。
  那次 45 個場景通過 26 個。在發布的檔案上重跑了 14 個：8 個每一步都通過，S9、S11、S33、S43 只在測試工具的檢查上失敗，S34 沒能開始（測試工具），S41 失敗（見下條）。S4、S8、S13、S23、S29、S44 在 rc.7.45 上沒有完整執行。
- 測試中的介面操作用的是 DevTools 自動化點選，不是人工按鍵。
- Windows 鎖定螢幕/解鎖和 UAC 這一步，依據是 Winlogon 事件和工作階段狀態未變；沒有即時螢幕錄影，取消 UAC
  的情況來自操作者本人的報告。
- macOS 上 VS Code 視窗被隱藏時，Terminal 文字可能要到執行結束才出現。
- Stata 自身的啟動仍算在執行前快照的 60 秒預算裡，只有服務連線有單獨的預算。在繁忙的 Windows
  機器上，開啟或重新載入後的第一次執行在 6 次冷啟動中被拒絕過 1 次（`PRE_RUN_SNAPSHOT_TIMEOUT`，
  程式碼沒有發出），下一次執行通過。
- 多行選取範圍（Run Selection 或 agent 選取範圍）裡，頂層的 `exit` 會結束整個選取範圍。它前面的
  程式碼已經執行，但請求按失敗傳回（HTTP 500），錯誤訊息取最後一行紅字。do 檔案裡或
  program 裡的 `exit` 不受影響。rc.7.44 就有這個問題。
- FULL45 S41 裡，手動 Run Selection 停在 Stata 錯誤上（r(603)，路徑用到了選取範圍上方定義的 global），結果報成失敗，但沒有帶傳回碼（「execution released without verified completion evidence」）。rc.7.44 也是這樣。本版沒有進一步調查。
- 一個 backend 一次只跑一個請求。多個執行個體需要各自的 profile 和連接埠；沒有通用的多執行個體排程。
- Data Browser 的 frame 名在瀏覽器開啟時更新，之後再 `frame change` 不會跟著變。面板較窄時
  FILTER 一行文字會重疊。
- 單獨的 `graph use` 不會在 Terminal 裡產生圖形卡片。
- 不保證顯示的原始碼與實際執行的位元組完全一致。
- `dist/extension.js` 是維護中的 bundle。另有一個參考原始碼建置，但它與 bundle 的功能等價尚未證明。
- 遠端桌面、所有 Stata 版本，以及測試過的路徑以外的長路徑，都未認證。

## 版本歷史

日期為 UTC。詳情見[變更紀錄](CHANGELOG.md)。

| Tag | 日期 | 類型 | 範圍 |
| --- | --- | --- | --- |
| `v0.1.3-rc.7.45` | 2026-10-31 | Pre-release | macOS 和 Windows：冷啟動後的第一次執行等 Stata 本身變成 running；等待期間按 Stop 仍是 soft Stop；Windows 上 force reset 等得起冷重連；agent 路徑上的命名圖形匯出（`set more off` 字首）；執行前 checkpoint 期間按 Stop 不再發送被拒的恢復命令；Windows 上 soft Stop 能恢復大型工作階段；成功的 do 檔案執行不再被報成失敗 |
| `v0.1.3-rc.7.44` | 2026-10-30 | Pre-release | macOS 和 Windows：Windows 相容層與驗收工具、執行前時段裡的 Stop 不再讓正文執行、唯讀探測逾時會重新觀測、backend 冷啟動不計入執行前預算、預設服務保持在 MCP 1.x、連上後再查取消、Stop 提示文字、Data Browser frame、已儲存圖形預覽、遞迴 DO 引用掃描 |
| `v0.1.3-rc.7.39-public.2` | 2026-09-09 | Pre-release | macOS 權限診斷（Mac tools 1.1.0）；執行階段不變 |
| `v0.1.3-rc.7.39-public.1` | 2026-09-07 | Pre-release | 對 Mac 驗收過的 `0.1.3-rc.7.39` 做公開打包；去掉本機維護 token |
| `docs-2026.09.26` | 2026-09-26 | 文件 | 只有文件；執行階段不變 |
| `v0.1.1` | 2026-05-19 | 正式版 | 教學範例和安裝文件 |
| `v0.1.0` | 2026-05-19 | 正式版 | 首個公開預發布版本 |

GitHub 把 `v0.1.1` 標為「Latest」，因為之後的版本都是 pre-release。

## 授權條款

AGPL-3.0-or-later。派生自 [tmonk/stata-workbench](https://github.com/tmonk/stata-workbench)。
與 [hanlulong/stata-mcp](https://github.com/hanlulong/stata-mcp) 的設計比較在 [NOTICE](NOTICE)
裡致謝，不表示兩者執行階段可以互換。見 [LICENSE](LICENSE) 和 [SECURITY.md](SECURITY.md)。

發布管道是 GitHub Releases。較早的 Open VSX 條目不是這個執行階段，Visual Studio Marketplace
上也沒有發布。

### 開發

```sh
npm ci --ignore-scripts
npm run check
python3 -B -m unittest discover -s tools -p 'test_*.py'
npm run package
python3 -B tools/verify_release.py --packaged
```

`npm run check` 唯讀，並有執行階段摘要守衛。`check:legacy` 是舊的會改寫檔案的流程，不要對已封存的
候選版執行。打包用的是帶版本的維護 bundle、可讀修補檔和介面原始碼，不是從上游 TypeScript 乾淨重建。
CI 在 macOS ARM、macOS Intel 和 Windows Server 2022 上執行，沒有 Stata、圖形介面或私有憑證。
改了執行階段就需要新版本和新的授權驗收，見[發布維護](docs/RELEASE.md)。
