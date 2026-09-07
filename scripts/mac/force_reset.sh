#!/usr/bin/env bash
# force_reset.sh — 清 Stata Workbench 桥的 busy 死角（Mac 版）
#
# Windows 对应：unblock_stata_terminal.ps1 的 force-reset + smoke 序列。
# 背景：graph run 后桥可能卡 busy:true + 陈旧 lastRun，新 run 秒回 409/500；
#       唯一解 = /force-reset，且必须再补一次 smoke 才恢复 trueReady（被动轮询不恢复）。
#
# 用法：
#   ./force_reset.sh              force-reset + verified smoke（仅 recovery.required=true 时）
#   ./force_reset.sh --no-smoke   只 force-reset，不补 smoke
#
# 退出码：0=恢复成功（smoke rc=0），2=force-reset 发出但 smoke 未确认，3=桥离线

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

DO_SMOKE=1
if [ $# -gt 1 ]; then
  err "用法：$0 [--no-smoke]"
  exit 2
fi
if [ $# -eq 1 ]; then
  if [ "$1" = "--no-smoke" ]; then
    DO_SMOKE=0
  else
    err "未知参数：$1"
    exit 2
  fi
fi

require_bridge_online

info "=== Stata 桥 force-reset ==="

# 1) force-reset（取消在途 run、清 busy；不清图面板）
log "[1/2] force-reset ..."
FR="$(bridge_post_empty /force-reset 30)"
fr_ok="$(json_field "$FR" '.ok')"
if [ "$fr_ok" != "true" ]; then
  err "  force-reset 未确认：$FR"
  exit 2
fi
ok "  force-reset ok"

sleep 3

recovery_required="$(json_field "$FR" '.recovery.required // .state.recovery.required // false')"
true_ready="$(json_field "$FR" '.trueReady // .state.trueReady // false')"

if [ "$recovery_required" != "true" ]; then
  if [ "$true_ready" = "true" ]; then
    ok "  无需 recovery smoke；桥已 trueReady。"
    exit 0
  fi
  warn "  force-reset 未要求 smoke，但 trueReady 也未确认。"
  exit 2
fi

if [ "$DO_SMOKE" = "0" ]; then
  warn "跳过 smoke（--no-smoke）。桥保持 recovery-required/trueReady=false。"
  exit 2
fi

# 2) smoke —— 端点内部生成 marker，调用方不能提供任意 Stata 代码
log "[2/2] verified recovery smoke ..."
SM="$(bridge_post_empty /recovery-smoke 120)"
sm_ok="$(json_field "$SM" '.ok')"
sm_rc="$(json_field "$SM" '.rc')"
sm_marker="$(json_field "$SM" '.markerVerified')"

if [ "$sm_ok" = "true" ] && [ "$sm_rc" = "0" ] && [ "$sm_marker" = "true" ]; then
  ok "  smoke ok=true rc=0 markerVerified=true —— 桥已恢复 trueReady。"
  exit 0
fi
warn "  smoke 未确认（ok=$sm_ok rc=$sm_rc markerVerified=$sm_marker）。桥保持 recovery-required。"
exit 2
