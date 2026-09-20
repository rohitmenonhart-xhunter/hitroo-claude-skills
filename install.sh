#!/usr/bin/env bash
# One-line install without node:  curl -fsSL https://raw.githubusercontent.com/rohitmenonhart-xhunter/hitroo-claude-skills/main/install.sh | bash
set -euo pipefail
REPO="https://github.com/rohitmenonhart-xhunter/hitroo-claude-skills"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
if command -v git >/dev/null 2>&1; then git clone --quiet --depth 1 "$REPO" "$TMP/repo"; else curl -fsSL "$REPO/archive/refs/heads/main.tar.gz" | tar -xz -C "$TMP" && mv "$TMP"/hitroo-claude-skills-main "$TMP/repo"; fi
for target in "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills"; do
  for s in "$TMP"/repo/plugins/*/skills/*/; do
    name="$(basename "$s")"; mkdir -p "$target"; rm -rf "$target/$name"; cp -R "$s" "$target/$name"; chmod +x "$target/$name"/scripts/* 2>/dev/null || true
    echo "installed $name → $target/$name"
  done
done
echo "Done. Open a new Claude Code session; the skill appears in its list."
