#!/usr/bin/env bash
# run_visible.sh — 通过 HTTP /run-command 在可见 Stata Terminal 执行代码/do 文件（Mac 版）
#
# Windows 对应：invoke_stata_visible.ps1 的 /run-command 路径。
# 用法：
#   ./run_visible.sh -c 'display "hello"'                     执行一段代码
#   ./run_visible.sh -f /abs/path/to/file.do                  执行整个 do 文件（do "file"）
#   ./run_visible.sh -c '...' --cwd /some/dir --label '冒烟'   指定工作目录/标签
#   ./run_visible.sh -f x.do --timeout 600                    自定义超时秒
#
# 说明：
#   - /run-command 是同步 HTTP，无 token 鉴权。它不会把 log 实时流进终端，
#     且对超大文件可能提前返回 fake-rc（见 MAINTENANCE_MAC.md §2）；需要实时流进终端用 run_native_disk0.sh。
#   - do 文件模式用 `do "<path>"` 单行注入，避免 native prepare 扫全文件卡死。
#   - 出错时自动 force-reset + 专用 verified recovery smoke，再重试一次。
#
# 退出码：0=ok 且 rc=0；1=执行失败/降级；3=桥离线；2=参数错误

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

CODE=""
DOFILE=""
CWD=""
LABEL="Mac Visible Run"
TIMEOUT=300

while [ $# -gt 0 ]; do
  case "$1" in
    -c|--code)    CODE="$2"; shift 2 ;;
    -f|--dofile)  DOFILE="$2"; shift 2 ;;
    --cwd)        CWD="$2"; shift 2 ;;
    --label)      LABEL="$2"; shift 2 ;;
    --timeout)    TIMEOUT="$2"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) err "未知参数：$1"; exit 2 ;;
  esac
done

# --- 组装要执行的 code ---
if [ -n "$DOFILE" ]; then
  if [ ! -f "$DOFILE" ]; then
    err "do 文件不存在：$DOFILE"
    exit 2
  fi
  # 转成绝对路径
  DOFILE="$(cd "$(dirname "$DOFILE")" && pwd)/$(basename "$DOFILE")"
  CODE="do \"$DOFILE\""
  [ -z "$CWD" ] && CWD="$(dirname "$DOFILE")"
fi

if [ -z "$CODE" ]; then
  err "必须提供 -c <code> 或 -f <dofile>。"
  exit 2
fi
[ -z "$CWD" ] && CWD="$PWD"

require_bridge_online

# --- 组 JSON body（jq 负责转义，避免注入）---
BODY="$(jq -nc \
  --arg code "$CODE" \
  --arg cwd "$CWD" \
  --arg label "$LABEL" \
  '{code:$code, cwd:$cwd, label:$label, source:"agent"}')"

info "=== 执行：$LABEL ==="
printf '  cwd     : %s\n' "$CWD"
printf '  code    : %s\n' "$(printf '%s' "$CODE" | head -c 120)"

run_once() {
  bridge_post_json "/run-command" "$BODY" "$TIMEOUT"
}

RESULT="$(run_once)"
CURL_RC=$?

# recovery-required 是结构化控制面状态，不是传输失败；直接走专用 smoke 后重试。
if [ $CURL_RC -eq 0 ] && [ -n "$RESULT" ] && printf '%s' "$RESULT" | jq -e . >/dev/null 2>&1; then
  REASON_CODE="$(json_field "$RESULT" '.reasonCode // ""')"
  if [ "$REASON_CODE" = "recovery-required" ]; then
    warn "桥要求 verified recovery smoke；完成验证后重试一次…"
    RECOVERY="$(bridge_post_empty "/recovery-smoke" 120)"
    if [ "$(json_field "$RECOVERY" '.ok')" != "true" ] || \
       [ "$(json_field "$RECOVERY" '.markerVerified')" != "true" ]; then
      err "verified recovery smoke 失败：$RECOVERY"
      exit 1
    fi
    RESULT="$(run_once)"
    CURL_RC=$?
  fi
fi

# --- HTTP 层失败（超时/500/连接错）→ 韧性恢复重试一次 ---
if [ $CURL_RC -ne 0 ] || [ -z "$RESULT" ] || ! printf '%s' "$RESULT" | jq -e . >/dev/null 2>&1; then
  warn "首次调用异常（curl_rc=$CURL_RC）；force-reset + verified smoke 后重试一次…"
  bridge_post_empty "/force-reset" 20 >/dev/null 2>&1
  RECOVERY="$(bridge_post_empty "/recovery-smoke" 120)"
  RECOVERY_OK="$(json_field "$RECOVERY" '.ok')"
  RECOVERY_REASON="$(json_field "$RECOVERY" '.reasonCode')"
  if [ "$RECOVERY_OK" != "true" ] && [ "$RECOVERY_REASON" != "recovery-not-required" ]; then
    err "verified recovery smoke 失败：$RECOVERY"
    exit 1
  fi
  sleep 2
  RESULT="$(run_once)"
  if [ -z "$RESULT" ] || ! printf '%s' "$RESULT" | jq -e . >/dev/null 2>&1; then
    err "重试后仍无有效 JSON 响应。桥可能仍在恢复；用 status.sh 复查、必要时 force_reset.sh。"
    err "原始响应：$(printf '%s' "$RESULT" | head -c 300)"
    exit 1
  fi
fi

R_OK="$(json_field "$RESULT" '.ok')"
R_RC="$(json_field "$RESULT" '.rc // "?"')"
R_RUNID="$(json_field "$RESULT" '.runId // .lastRunId // "?"')"

printf '  ok      : %s\n' "$R_OK"
printf '  rc      : %s\n' "$R_RC"
printf '  runId   : %s\n' "$R_RUNID"

if [ "$R_OK" = "true" ] && [ "$R_RC" = "0" ]; then
  ok "执行成功。"
  exit 0
fi
warn "执行返回非成功（ok=$R_OK rc=$R_RC）。注意 rc=0/ok=false 是假完成签名，务必核对 stdout 与落盘产物。"
exit 1
