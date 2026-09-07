#!/usr/bin/env bash
# run_native_disk0.sh — 通过 native /debug-run-file 执行 do 文件（Mac 版，日志实时流进终端）
#
# Windows 对应：invoke_stata_visible.ps1 的 -UseRunFileHandler / debug-run-file 路径。
# 用法：
#   ./run_native_disk0.sh /abs/path/to/file.do             disk=0（跳过 inline-snapshot prepare）
#   ./run_native_disk0.sh /abs/path/to/file.do --disk 1    disk=1（含快照准备，超大文件会卡）
#   ./run_native_disk0.sh file.do --timeout 900
#
# 关键取舍（见 MAINTENANCE_MAC.md §2）：
#   - /debug-run-file 是唯一把 log 实时流进 Stata Terminal 的通道。
#   - disk=0 跳过 inline-snapshot 准备阶段；对上万行大文件 prepare 会在 host 进程卡死，
#     故大文件默认用 disk=0；小文件两者皆可。
#   - 若 native prepare 对某文件卡死，改用 run_visible.sh（HTTP do "file"）。
#
# 退出码：0=ok；1=失败；2=参数错误；3=桥离线

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

DOFILE=""
DISK=0
TIMEOUT=600

while [ $# -gt 0 ]; do
  case "$1" in
    --disk)     DISK="$2"; shift 2 ;;
    --timeout)  TIMEOUT="$2"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    -*) err "未知参数：$1"; exit 2 ;;
    *)  DOFILE="$1"; shift ;;
  esac
done

if [ -z "$DOFILE" ]; then
  err "必须提供 do 文件路径。"
  exit 2
fi
if [ ! -f "$DOFILE" ]; then
  err "do 文件不存在：$DOFILE"
  exit 2
fi
DOFILE="$(cd "$(dirname "$DOFILE")" && pwd)/$(basename "$DOFILE")"

require_bridge_online

# --- URL 编码 path（jq 的 @uri）---
ENC_PATH="$(printf '%s' "$DOFILE" | jq -sRr @uri)"
URI="/debug-run-file?disk=${DISK}&path=${ENC_PATH}"

info "=== native 执行（实时流进终端）==="
printf '  file    : %s\n' "$DOFILE"
printf '  disk    : %s\n' "$DISK"
printf '  timeout : %ss\n' "$TIMEOUT"

RESULT="$(bridge_post_json "$URI" "" "$TIMEOUT")"
CURL_RC=$?

if [ $CURL_RC -ne 0 ] || [ -z "$RESULT" ] || ! printf '%s' "$RESULT" | jq -e . >/dev/null 2>&1; then
  err "native 调用异常（curl_rc=$CURL_RC）。可能是 prepare 阶段卡死（大文件常见）。"
  err "建议改用 run_visible.sh（HTTP do \"file\"）；或先 force_reset.sh 再试。"
  err "原始响应：$(printf '%s' "$RESULT" | head -c 300)"
  exit 1
fi

R_OK="$(json_field "$RESULT" '.ok')"
R_RAN="$(json_field "$RESULT" '.ran // "?"')"
R_PATH="$(json_field "$RESULT" '.humanFileDebug.path // .path // "?"')"

printf '  ok      : %s\n' "$R_OK"
printf '  ran     : %s\n' "$R_RAN"
printf '  path    : %s\n' "$R_PATH"

if [ "$R_OK" = "true" ]; then
  ok "native 执行完成（务必核对终端 log 尾与落盘产物；native 通道 worker CPU 信号不可靠）。"
  exit 0
fi
warn "native 执行返回 ok=false。核对 stdout 与落盘产物再判成败。"
exit 1
