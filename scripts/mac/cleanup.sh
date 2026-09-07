#!/usr/bin/env bash
# cleanup.sh — 清理孤儿 mcp-stata / uvx / uv 辅助进程（Mac 版）
#
# Windows 对应：cleanup_mcp_stata_processes.ps1。
# 目的：force-reset 后可能残留跑飞的 mcp-stata worker（PyStata 嵌入进程）；
#       本脚本按命令行特征精确匹配它们，默认只列不杀（dry-run），--force 才真杀。
#
# 红线（与 MEMORY 一致）：
#   - 只杀命中 mcp-stata 特征的进程，按 exact PID 逐个杀。
#   - 绝不 blanket pkill Stata，绝不动 Code/VS Code/当前 shell。
#
# 用法：
#   ./cleanup.sh            dry-run，列出候选
#   ./cleanup.sh --force --pid 123 --pid 456
#
# 退出码：0=成功（或 dry-run），1=有进程杀不掉

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

FORCE=0
OWNED_PIDS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --pid)
      if ! [[ "${2:-}" =~ ^[0-9]+$ ]] || [ "${2:-0}" -le 1 ]; then
        err "--pid 必须是大于 1 的整数。"
        exit 2
      fi
      OWNED_PIDS+=("$2")
      shift 2
      ;;
    *)
      err "未知参数：$1"
      exit 2
      ;;
  esac
done

if [ "$FORCE" = "1" ] && [ "${#OWNED_PIDS[@]}" -eq 0 ]; then
  err "拒绝全局清理：--force 必须至少提供一个由当前扩展宿主登记的 --pid。"
  exit 2
fi

SELF_PID=$$
PARENT_PID=$PPID

# 命中特征：命令行同时含 mcp-stata（辅助进程 / uvx 启动 / uv tool 启动 / venv Scripts）
# 用 ps -Ao pid,comm,args 全量列，再按 args 关键字过滤。
info "=== 扫描 mcp-stata 相关进程 ==="

CANDIDATES=()
while read -r pid args; do
  # read 会忽略 ps 的前导空格，并把剩余命令行完整放入 args。
  [ -n "$pid" ] || continue

  # 跳过自身与父进程
  [ "$pid" = "$SELF_PID" ] && continue
  [ "$pid" = "$PARENT_PID" ] && continue

  if [ "${#OWNED_PIDS[@]}" -gt 0 ]; then
    requested=0
    for owned_pid in "${OWNED_PIDS[@]}"; do
      [ "$pid" = "$owned_pid" ] && requested=1 && break
    done
    [ "$requested" = "1" ] || continue
  fi

  # 保护：绝不碰编辑器 / Stata GUI 本体 / 登录 shell
  case "$args" in
    *"Visual Studio Code"*|*"Code Helper"*|*"/Code"*) continue ;;
    *"/Applications/Stata"*|*"StataMP"*|*"StataSE"*|*"StataBE"*) continue ;;
  esac

  # 命中：命令行含 mcp-stata（且是 uvx/uv/python worker 形态）
  case "$args" in
    *mcp-stata*)
      # 进一步确认是 helper 形态，排除本类脚本自身对 mcp-stata 的文本引用
      case "$args" in
        *uvx*|*"uv tool"*|*"/mcp-stata"*|*"mcp-stata=="*|*"cpython-"*mcp-stata*|*"mcp_stata"*)
          CANDIDATES+=("$pid|$args")
          ;;
        *python*mcp-stata*)
          CANDIDATES+=("$pid|$args")
          ;;
      esac
      ;;
  esac
done < <(ps -Ao pid=,args= 2>/dev/null)

if [ "${#CANDIDATES[@]}" -eq 0 ]; then
  ok "无 mcp-stata 孤儿进程候选。"
  exit 0
fi

info "候选进程（${#CANDIDATES[@]} 个）："
for entry in "${CANDIDATES[@]}"; do
  pid="${entry%%|*}"
  args="${entry#*|}"
  # 截断超长命令行
  short="${args:0:140}"
  printf '  pid=%-7s %s\n' "$pid" "$short"
done

if [ "$FORCE" = "0" ]; then
  warn "dry-run 模式：未杀任何进程。确认无误后加 --force 真杀。"
  exit 0
fi

info "=== 逐个 kill（exact PID）==="
FAILED=0
is_running() {
  local target_pid="$1"
  local state
  kill -0 "$target_pid" 2>/dev/null || return 1
  state="$(ps -o stat= -p "$target_pid" 2>/dev/null | tr -d '[:space:]')"
  case "$state" in
    Z*) return 1 ;;
  esac
  return 0
}
for entry in "${CANDIDATES[@]}"; do
  pid="${entry%%|*}"
  if ! is_running "$pid"; then
    log "  pid=$pid 已退出，跳过。"
    continue
  fi
  kill -TERM "$pid" 2>/dev/null
  sleep 1
  if is_running "$pid"; then
    # TERM 不掉，升级 KILL
    kill -KILL "$pid" 2>/dev/null
    sleep 1
  fi
  if is_running "$pid"; then
    err "  pid=$pid 杀不掉。"
    FAILED=1
  else
    ok "  pid=$pid 已终止。"
  fi
done

if [ "$FAILED" = "1" ]; then
  err "部分进程未能终止。"
  exit 1
fi
ok "清理完成。"
exit 0
