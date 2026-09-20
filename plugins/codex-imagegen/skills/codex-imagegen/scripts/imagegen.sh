#!/usr/bin/env bash
# Generate one image with Codex's image tool from a brief, save it into <out-dir>/<file.png>, verify it.
#   imagegen.sh <out-dir> <file.png> "<brief>"        env: CODEX_BIN, IMAGEGEN_TIMEOUT (s, default 900)
set -euo pipefail
if [ $# -lt 3 ]; then echo "usage: imagegen.sh <out-dir> <file.png> \"<brief>\"" >&2; exit 2; fi
OUT_DIR="$1"; FILE="$2"; BRIEF="$3"
mkdir -p "$OUT_DIR"; OUT_DIR="$(cd "$OUT_DIR" && pwd)"
find_codex() {
  if [ -n "${CODEX_BIN:-}" ] && "$CODEX_BIN" --version >/dev/null 2>&1; then echo "$CODEX_BIN"; return; fi
  for c in "$(command -v codex 2>/dev/null || true)" "/Applications/ChatGPT.app/Contents/Resources/codex" "$HOME/.codex/plugins/.plugin-appserver/codex"; do
    [ -n "$c" ] && [ -x "$c" ] && "$c" --version >/dev/null 2>&1 && { echo "$c"; return; }
  done
  return 1
}
CODEX="$(find_codex)" || { echo "no working codex binary found (tried PATH, the ChatGPT app, ~/.codex/plugins); install Codex or set CODEX_BIN" >&2; exit 3; }
PROMPT="Use your image generation tool to create ONE image and save it into this directory as ${FILE} (copy the generated PNG file here under exactly that name; keep it as PNG; do not create anything else). Brief: ${BRIEF} When done, reply with only the absolute path of ${FILE} and its pixel size."
echo "codex: $CODEX" >&2
if command -v timeout >/dev/null 2>&1; then TO="timeout ${IMAGEGEN_TIMEOUT:-900}"; else TO=""; fi
$TO "$CODEX" exec --skip-git-repo-check -s workspace-write -C "$OUT_DIR" "$PROMPT" 2>/tmp/imagegen.$$.err | tail -3 || true
if [ ! -s "$OUT_DIR/$FILE" ]; then
  echo "image not produced: $OUT_DIR/$FILE" >&2; tail -20 /tmp/imagegen.$$.err >&2; exit 4
fi
rm -f /tmp/imagegen.$$.err
python3 "$(dirname "$0")/png_check.py" "$OUT_DIR/$FILE"
