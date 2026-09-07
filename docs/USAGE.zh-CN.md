# 人与 AI 共享 Stata 会话使用指南

## 打开和人工使用

通过 VS Code 的「Extensions: Install from VSIX...」安装 Release 下载的 VSIX。
设置 `stataMcp.stataPath`，执行「Stata: Open Interactive Terminal」。
需要 AI 接入时，按 [完整安装命令](QUICKSTART.md) 使用独立 profile。

打开 `.do` 文件，用「Stata: Run Current File」运行整份文件，或用
「Stata: Run Selection/Current Line」运行选中内容。结果在 Stata Terminal，
图在 Stata Graphs。清除显示不等于清除数据；长任务结束前不要重复提交。

## AI 接入

AI 必须使用同一 profile、同一端口的 `tools/shared_stata.py`，不另起隐藏 Stata。
`tools/verified_workbench.py --status` 只检查，`--open` 复用现有窗口。
[快速开始](QUICKSTART.md) 提供人工创建 40、AI 改为 42、人工读取并清理的例子。

共享同一 backend 的数据、宏、scalar 和结果，不是两份内存同步。人和 AI
轮流操作；busy、恢复未完成、实例不唯一或身份不符时工具会拒绝。
`.stata-receipts/` 回执含代码和日志，保持私有。

## 停止与恢复

先用界面停止功能，检查是否完整恢复、是否重新 ready。不要把部分恢复当成功。
未确认的执行不自动重试，先查日志避免重复写入。不要以重启、clear all 或
强制删文件作为默认修复。重要结果必须保存到磁盘，关闭应用后不保证恢复内存。

## 验收范围

固定 Mac 运行时有 FULL45 45/45、632/632 和共享 backend 的记录。
公开包已移除本机 token，包哈希不同，运行时 bundle 相同。
不是所有系统和版本的保证，Windows/Linux 未获得本轮认证。
详见 [验收说明](ACCEPTANCE.md)。
