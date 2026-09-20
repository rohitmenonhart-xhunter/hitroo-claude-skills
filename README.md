# Hitroo skills for Claude Code

Skills that any Claude Code session can use, on any machine, installed with one command.

| Skill | What it does |
|---|---|
| `codex-imagegen` | Real pictures from a written brief through Codex's image generation tool: illustrations, hero art, icons, transparent PNG cut-outs; verifies and sizes them for the web. Needs the Codex CLI signed in to ChatGPT. |

## Install

As a Claude Code plugin (recommended; updates with `claude plugin update`):

```bash
claude plugin marketplace add rohitmenonhart-xhunter/hitroo-claude-skills
claude plugin install codex-imagegen@hitroo-skills
```

Or copy the skills into `~/.claude/skills` (also `~/.codex/skills` and `~/.agents/skills`, so Codex and other agents see them):

```bash
npx github:rohitmenonhart-xhunter/hitroo-claude-skills
# or, without node:
curl -fsSL https://raw.githubusercontent.com/rohitmenonhart-xhunter/hitroo-claude-skills/main/install.sh | bash
```

Uninstall the copied skills with `npx github:rohitmenonhart-xhunter/hitroo-claude-skills --uninstall`; a plugin with `claude plugin uninstall codex-imagegen@hitroo-skills`.

## Use

In any project: "generate an illustration of …" or `/codex-imagegen`. Claude writes the brief in the shape
the skill describes (subject, style, palette in hex, transparent background, size and where the empty space
goes), runs `scripts/imagegen.sh`, looks at the picture, and wires it in. The brief recipe, checks and
pitfalls are in `plugins/codex-imagegen/skills/codex-imagegen/SKILL.md`.

## Add a skill

Put it under `plugins/<plugin>/skills/<skill>/SKILL.md` (frontmatter `name` + `description`, scripts in
`scripts/`), list the plugin in `.claude-plugin/marketplace.json`, bump the version, push.
