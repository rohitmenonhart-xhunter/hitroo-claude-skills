#!/usr/bin/env node
// Copies every skill under plugins/*/skills/ into the user-level skill folders of Claude Code, Codex and
// other agents that read ~/.agents/skills. Idempotent: re-running updates in place.
//   npx github:rohitmenonhart-xhunter/hitroo-claude-skills          (or: npx @hitroo/claude-skills once published)
//   hitroo-skills --uninstall                                          removes them again
const fs = require("fs");
const os = require("os");
const path = require("path");

const root = path.resolve(__dirname, "..");
const uninstall = process.argv.includes("--uninstall");
const targets = [
  path.join(os.homedir(), ".claude", "skills"),
  path.join(os.homedir(), ".codex", "skills"),
  path.join(os.homedir(), ".agents", "skills"),
];
const skills = [];
for (const plugin of fs.readdirSync(path.join(root, "plugins"))) {
  const dir = path.join(root, "plugins", plugin, "skills");
  if (!fs.existsSync(dir)) continue;
  for (const s of fs.readdirSync(dir)) if (fs.existsSync(path.join(dir, s, "SKILL.md"))) skills.push([s, path.join(dir, s)]);
}
if (!skills.length) { console.error("no skills found in package"); process.exit(1); }
for (const target of targets) {
  for (const [name, src] of skills) {
    const dest = path.join(target, name);
    if (uninstall) { if (fs.existsSync(dest)) { fs.rmSync(dest, { recursive: true, force: true }); console.log(`removed ${dest}`); } continue; }
    fs.mkdirSync(target, { recursive: true });
    fs.rmSync(dest, { recursive: true, force: true });
    fs.cpSync(src, dest, { recursive: true });
    for (const f of fs.readdirSync(path.join(dest, "scripts"), { withFileTypes: true })) if (f.isFile()) fs.chmodSync(path.join(dest, "scripts", f.name), 0o755);
    console.log(`installed ${name} → ${dest}`);
  }
}
if (!uninstall) console.log("\nDone. Open a new Claude Code session; the skills appear in its list (or type /codex-imagegen, /claude-computer-use).\nAlso works as Claude Code plugins: claude plugin marketplace add rohitmenonhart-xhunter/hitroo-claude-skills && claude plugin install codex-imagegen@hitroo-skills claude-computer-use@hitroo-skills");
