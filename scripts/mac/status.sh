#!/usr/bin/env bash
# status.sh — 查 Stata Workbench 桥状态（Mac 版，只读）
#
# Windows 对应：各 ps1 里 Invoke-RestMethod /status 片段。
# 用法：
#   ./status.sh          人类可读摘要
#   ./status.sh --json   打印原始 /status JSON
#
# 退出码：0=桥在线且 trueReady，2=在线但降级/busy，3=桥离线

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

RAW_JSON=0
[ "$1" = "--json" ] && RAW_JSON=1

STATUS="$(bridge_status)"
if [ -z "$STATUS" ]; then
  err "桥离线：${BRIDGE_BASE}/status 无响应。"
  exit 3
fi

if [ "$RAW_JSON" = "1" ]; then
  printf '%s\n' "$STATUS" | jq .
  exit 0
fi

# 注：本桥 /status 顶层键 = bridge/busy/postRunBusy/status/trueReady/notReadyReason/patch/graphPanel。
# platform/arch/lastRun 等字段本桥不在 /status 暴露（Windows 手册所列与此实现不同）。
# 注：jq 的 `//` 对布尔 false 会「穿透」当成空，故布尔字段用 `if ==null` 显式判空，保留 false 原值。
bridge_name="$(json_field "$STATUS" '.bridge // "?"')"
busy="$(json_field "$STATUS" '.busy // false')"
post_busy="$(json_field "$STATUS" 'if .postRunBusy==null then "?" else .postRunBusy end')"
status_str="$(json_field "$STATUS" '.status // "?"')"
true_ready="$(json_field "$STATUS" 'if .trueReady==null then "?" else .trueReady end')"
not_ready="$(json_field "$STATUS" '.notReadyReason // "-"')"
patch="$(json_field "$STATUS" '.patch // "?"')"
last_runid="$(json_field "$STATUS" '.graphPanel.lastRunId // "?"')"
clear_count="$(json_field "$STATUS" '.graphPanel.clearCount // "?"')"
img_ok="$(json_field "$STATUS" 'if .graphPanel.lastImageLoadOk==null then "?" else .graphPanel.lastImageLoadOk end')"

info "=== Stata Workbench 桥状态 (${BRIDGE_BASE}) ==="
printf '  bridge        : %s\n' "$bridge_name"
printf '  patch         : %s\n' "$patch"
printf '  status        : %s   busy=%s   postRunBusy=%s   trueReady=%s\n' "$status_str" "$busy" "$post_busy" "$true_ready"
printf '  notReadyReason: %s\n' "$not_ready"
printf '  graphPanel    : lastRunId=%s  clearCount=%s  lastImageLoadOk=%s\n' "$last_runid" "$clear_count" "$img_ok"

# 退出码：busy / postRunBusy / 非 trueReady 记为降级（2）
if [ "$busy" = "true" ] || [ "$post_busy" = "true" ] || [ "$true_ready" = "false" ]; then
  warn "桥在线但处于 busy/降级状态（可能需要 force-reset + smoke）。"
  exit 2
fi
ok "桥在线且就绪。"
exit 0
