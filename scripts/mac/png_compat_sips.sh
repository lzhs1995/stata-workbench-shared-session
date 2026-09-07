#!/bin/sh
# Darwin PNG_COMPAT convert helper (no Node).
# Direct sips PID tracking; timeout kills real sips process.
set -u

SVG=""
OUT=""
FORMAT="png"
WIDTH="1200"
TIMEOUT="90"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --svg) SVG="${2:-}"; shift 2 ;;
    --out) OUT="${2:-}"; shift 2 ;;
    --format) FORMAT="${2:-png}"; shift 2 ;;
    --width) WIDTH="${2:-1200}"; shift 2 ;;
    --timeout) TIMEOUT="${2:-90}"; shift 2 ;;
    *) shift ;;
  esac
done

fail() {
  echo "PNG_COMPAT_CONVERT_FAILED: $*" >&2
  exit 1
}

[ -n "$SVG" ] || fail "missing --svg"
[ -n "$OUT" ] || fail "missing --out"
[ -f "$SVG" ] || fail "svg_missing:$SVG"
[ -x /usr/bin/sips ] || fail "sips_missing"

case "$FORMAT" in
  png|PNG) FORMAT=png; EXT=png ;;
  jpg|jpeg|JPG|JPEG) FORMAT=jpeg; EXT=jpg ;;
  *) fail "bad_format:$FORMAT" ;;
esac

DIR=$(dirname "$OUT")
STAGE="${DIR}/.pngcompat_stage_$$.${EXT}"
RENDER="${DIR}/.pngcompat_render_$$.${EXT}"
MARKER="${OUT}.__pngcompat_ok"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RGB_HELPER="${SCRIPT_DIR}/png_opaque_rgb.rb"
rm -f "$STAGE" "$RENDER" "$MARKER" 2>/dev/null || true

if [ "$FORMAT" = "png" ]; then
  SIPS_OUT="$RENDER"
else
  SIPS_OUT="$STAGE"
fi

# Run sips directly in background so we track the real PID (not a wrapper shell).
/usr/bin/sips -s format "$FORMAT" --resampleWidth "$WIDTH" "$SVG" --out "$SIPS_OUT" >/dev/null 2>&1 &
SIPSPID=$!
ELAPSED=0
while kill -0 "$SIPSPID" 2>/dev/null; do
  if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
    kill -TERM "$SIPSPID" 2>/dev/null || true
    sleep 1
    kill -KILL "$SIPSPID" 2>/dev/null || true
    # also try process group if sips reparented children
    kill -TERM -"$SIPSPID" 2>/dev/null || true
    wait "$SIPSPID" 2>/dev/null || true
    rm -f "$STAGE" "$RENDER" 2>/dev/null || true
    fail "sips_timeout:${TIMEOUT}s:pid=$SIPSPID"
  fi
  sleep 1
  ELAPSED=$((ELAPSED + 1))
done
wait "$SIPSPID"
RC=$?
[ "$RC" = "0" ] || fail "sips_failed:rc=$RC:pid=$SIPSPID"
[ -f "$SIPS_OUT" ] || fail "render_missing"

if [ "$FORMAT" = "png" ]; then
  [ -f "$RGB_HELPER" ] || fail "rgb_helper_missing:$RGB_HELPER"
  [ -x /usr/bin/ruby ] || fail "ruby_missing"
  /usr/bin/ruby "$RGB_HELPER" "$RENDER" "$STAGE" >/dev/null 2>&1 || {
    rm -f "$STAGE" "$RENDER" 2>/dev/null || true
    fail "rgba_to_rgb_failed"
  }
  rm -f "$RENDER" 2>/dev/null || true
fi

[ -f "$STAGE" ] || fail "stage_missing"

BYTES=$(wc -c <"$STAGE" | tr -d ' ')
[ "${BYTES:-0}" -ge 32 ] || fail "stage_too_small:$BYTES"

if [ "$FORMAT" = "png" ]; then
  SIG=$(dd if="$STAGE" bs=8 count=1 2>/dev/null | od -An -tx1 | tr -d ' \n')
  echo "$SIG" | grep -qi '^89504e470d0a1a0a$' || fail "bad_png_signature:$SIG"
  COLOR_TYPE=$(dd if="$STAGE" bs=1 skip=25 count=1 2>/dev/null | od -An -tu1 | tr -d ' \n')
  [ "$COLOR_TYPE" = "2" ] || fail "png_not_rgb:color_type=$COLOR_TYPE"
fi

mv -f "$STAGE" "$OUT" || fail "rename_failed"
: >"$MARKER" || fail "marker_write_failed"
# codex patch rc.7.10.19: Stata/PyStata may not drain repeated shell output.
# The output file plus atomic success marker are authoritative, so success is silent.
exit 0
