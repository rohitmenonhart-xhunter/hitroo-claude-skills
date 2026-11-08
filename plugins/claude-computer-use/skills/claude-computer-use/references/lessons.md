# Lessons from real runs

These come from running the skill on a real Mac (Codex CLI 0.160, November 2026). Add to them when a run teaches something new.

## The run itself

- **Hangs on "Reading additional input from stdin…"**: stdin was never closed. `scripts/cu.sh` adds `</dev/null`. Keep it if you call `codex exec` yourself.
- **"Computer Use was not approved to use <app>"**: either an approval reviewer refused, or the app was never allowed.
  - `--approve-for-me` sends every approval to Codex's automatic reviewer, which refuses app access. `cu.sh` runs with `approval_policy="never"` instead.
  - The sandbox matters too. Under `-s workspace-write`, Computer Use access to Chrome was refused, and under `-s danger-full-access` it worked (both tested 8 November 2026). So `cu.sh` defaults to full access and says so; the task's rules are what limit it.
  - If the app has truly never been allowed, the user runs one Codex prompt in Terminal and approves it there. That approval is theirs to give. Never edit Computer Use's settings to get around it.
- **Browser use or Computer Use.** Codex's built-in instructions prefer its Chrome plugin (browser use, driven over CDP) unless told otherwise. `cu.sh` switches off `browser_use`, `browser_use_external`, `browser_use_full_cdp_access` and `in_app_browser`, and tells Codex to use `cua.getApp("<app>")`. The app is then driven as a person would drive it: in their signed-in sessions, on screen, where they can watch.
- **Fast mode** is the `priority` service tier, described as "Fast: 2x speed, increased usage" for gpt-6.1-sol. `cu.sh` defaults to `-m gpt-6.1-sol`, `model_reasoning_effort="high"` and `service_tier="priority"`. Change them with `CU_MODEL`, `CU_EFFORT` and `CU_TIER`.
- **Timing.**
  - A profile edit with a photo upload took about 2 minutes.
  - A bio edit took about 1 minute.
  - Run `cu.sh` in the background and wait for it to finish.
- **What happened in a run**, including one the user started themselves: the newest file in `~/.codex/sessions/<yyyy>/<mm>/<dd>/` is the session log (JSONL). Its last assistant messages hold the report.
- **macOS permissions.** Computer Use needs Screen Recording and Accessibility for "Codex Computer Use" (System Settings > Privacy & Security).

## Instagram on instagram.com (Chrome)

| Change | On the web? | How |
| --- | --- | --- |
| Profile photo | Yes | Edit profile > Change photo > Upload. In the file dialog, press Cmd+Shift+G and paste the path. |
| Name | Yes | It may route through Accounts Center. Instagram allows 2 name changes in 14 days. |
| Bio | Yes | Edit profile > Bio > Submit. |
| Link in bio | **No** | Phone app only: Edit profile > Links. |
| Archive a post | **No** | Phone app only: post > ⋯ > Archive. |
| Profile photo, name or bio through an API | No | Instagram's Graph API can't change them, and that gap is what this skill fills. |
