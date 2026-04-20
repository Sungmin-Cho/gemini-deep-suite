# deep-work (Gemini CLI edition) v0.1.0

Evidence-Driven Development Protocol — `/deep-work "task"` 하나로 Brainstorm → Research → Plan → Implement → Test 전체 워크플로우를 자동 진행하는 Gemini CLI extension. Port of [claude-deep-work](https://github.com/Sungmin-Cho/claude-deep-work) v6.3.0.

## Structure

```
gemini-extension.json          # Extension manifest
GEMINI.md                       # This file (auto-loaded context)
skills/                         # 24 skills (CC commands/skills consolidated)
  deep-work/SKILL.md            # Main orchestrator
  deep-{brainstorm,research,plan,implement,test}/SKILL.md   # Phase skills
  deep-integrate/               # Phase 5 integrate (schema, fixtures, scripts)
  deep-{status,finish,fork,history,resume,...}/SKILL.md      # Utility skills
  shared/references/*.md        # 14 guide documents
hooks/                          # Lifecycle hooks
  hooks.json
  scripts/*.{sh,js}             # Rewritten for Gemini stdin JSON + tool names
sensors/                        # Ecosystem detection (JS, TS, Python, C#, C++)
health/                         # Drift + fitness checks
templates/                      # Topology detectors + CI template
assumptions.json                # Hook enforcement baseline
```

## Quick start

```bash
gemini extensions install https://github.com/sungmin-cho/gemini-deep-work
gemini
# inside REPL:
/deep-work "Build a login page with email + password"
```

Auto-flow 5 phases will run. Each phase transition asks "진행?" via `ask_user` tool; confirm to continue.

## v0.1.0 limitations

See [docs/migration-from-claude-code.md](../../docs/migration-from-claude-code.md) in the monorepo (also published in the mirror repo's `docs/`).

- **Solo mode only** — no Team mode (parallel dispatch)
- **MultiEdit atomicity** — replaced with transactional pre-validation pattern
- **Per-command tool gates** — hook enforcement + skill body prose
- **Runtime state namespace** — `.gemini/deep-work/state-<session>.md` (NOT `.claude/`)

## Session state

Location: `.gemini/deep-work/state-<SESSION_ID>.md` (YAML frontmatter + body). See `skills/deep-work/SKILL.md` for field definitions.

## Hooks

- SessionStart — update-check + sensor detect
- BeforeTool (write_file|replace|run_shell_command|write_todos|save_memory|tracker_*) — phase-guard enforcement
- AfterTool — file-tracker (includes merged phase-transition logic, β path from Slice 0 spike)
- SessionEnd — session history JSONL append

Block decisions use `exit 0 + stdout JSON {decision:"deny", reason:"..."}` (Gemini idiomatic).

## License

MIT — see LICENSE.
