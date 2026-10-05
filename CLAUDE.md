# Setup instructions for Claude

You are reading this because the user pointed you at this repository. Your job is to help them **install the skills they want** from it. Follow this protocol exactly — do not improvise an install.

## When the user asks to set up / install / add these skills (or just "set this up")

0. **Prerequisite gate — check for Dynatrace for AI first.** This package does **not** work without the official skills from https://github.com/Dynatrace/dynatrace-for-ai. Run `./install.sh --check` (read-only). If it reports missing skills, **stop**: tell the user to install https://github.com/Dynatrace/dynatrace-for-ai first (`npx skills add dynatrace/dynatrace-for-ai`, or `claude plugin install dynatrace@claude-plugins-official`, or clone + copy its `skills/`), and do not continue until the check passes. Never install dynatrace-for-ai skills from this repo — it intentionally does not vendor them.
1. **Enter plan mode immediately.** Do **not** copy, write, register, or modify anything until the user approves a plan. Setup is a plan-first operation.
2. **Build the catalog.** Find every `SKILL.md` under `skills/` (they may be nested in category folders). For each, show its folder name and the one-line `description:` from its frontmatter. Group by category folder if present.
3. **Offer two selection modes and ask the user which they want:**
   - **Prescriptive** — they pick specific skills by name or number (accept lists and ranges), **or**
   - **Select all** — install every skill.
   If `skills/references/` exists, treat it as shared dependency files (e.g. `dt-brand` needs them) — include it automatically whenever a skill that depends on it is selected, or with "all".
4. **Present the plan via ExitPlanMode.** Spell out: the exact skills to install, that each `skills/<name>/` copies to `~/.claude/skills/<name>/` (and `skills/references/` → `~/.claude/skills/references/` if included), and **explicitly flag any skill that already exists and would be overwritten**.
5. **Only after approval, apply it:** run `./install.sh <skill> [<skill> …]` (or `./install.sh` for all). It re-checks the prerequisite and copies into `~/.claude/skills/` (honoring `$CLAUDE_CONFIG_DIR/skills`). Never touch skills the user didn't choose.
6. **Report** what was installed, and remind the user that Claude Code auto-discovers skills from `~/.claude/skills/` (run `/skills` or restart to see them). Surface any prerequisites noted in `README.md`.

## Rules
- **Plan first, always.** Never install before the user approves the plan.
- **Never install or overwrite a skill the user didn't explicitly select.** Flag overwrites in the plan.
- No secrets, customer data, or tenant IDs live in this repo; keep it that way.
- **No dynatrace-for-ai skills here.** This repo ships only new skills built on top of dynatrace-for-ai; never add copies of upstream skills (`dt-obs-*`, `dt-dql-essentials`, `dt-app-*`, `dt-migration`, …).
- This repo contains skill folders, docs, and `install.sh` — there is nothing to build or compile.
