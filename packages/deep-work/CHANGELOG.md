# Changelog

## [0.1.0] — 2026-04-20

Initial release — Gemini CLI 0.35.0 port of `claude-deep-work v6.3.0`.

### Added

- **25 skills** (CC 24 commands + CC 8 skills consolidated via `SkillCommandLoader` auto-registration — each CC command body becomes a Gemini skill, with `deep-work-orchestrator` renamed to `deep-work` to match the primary slash command)
- **Hook system** with 8 mutating-tool matcher: `write_file | replace | run_shell_command | write_todos | save_memory | tracker_create_task | tracker_update_task | tracker_add_dependency`
  - `SessionStart` (startup/resume/clear/compact) — update-check + sensor detect
  - `BeforeTool` — phase-guard enforcement (TDD, worktree, Phase 5 allowlist)
  - `AfterTool` — file-tracker + sensor-trigger + phase-transition checklist
  - `SessionEnd` — session-end history log
- **Sensors**: JS, TS, Python, C#, C++ ecosystems (detect.js, run-sensors.js, 8 parsers)
- **Health engine**: drift detection (coverage-trend, dead-export, dependency-vuln, stale-config), fitness functions (4 rule-checkers), health-check
- **Templates**: 6 topologies (nextjs-app, react-spa, express-api, python-web, python-lib, generic) + topology-detector
- **`deep-integrate` skill**: full Phase 5 Integrate with schema/fixtures/shell-scripts (`phase5-finalize.sh`, `gather-signals.sh`, `detect-plugins.sh`)
- **Transactional MultiEdit pattern** — skill body guides LLM to pre-validate all replace pairs before committing (replaces CC's atomic `MultiEdit`)
- **`.gemini/deep-work/` runtime state namespace** — no collision with CC `.claude/`

### Test coverage

- 557/557 tests passing (100%)
  - hooks/scripts: 398 tests
  - sensors/health/templates: 122 tests
  - skills/deep-integrate: 37 tests

### Migration tooling

- `scripts/extract-hook-hardcodes.sh` — 자동 catalog generator (env / literal tool names / abs paths)
- `scripts/migrate-skills.mjs` — CC commands + skills → Gemini skill body transformer
- `scripts/migrate-hooks.mjs` — CC hooks → Gemini hooks automated (stdin parser injection, tool rename, path rewrite)
- `scripts/publish-subtree.sh` — git subtree split → mirror repo push

### Solo-mode limitations (deferred to v0.2.0+)

- Team mode / parallel subagent dispatch (`--team` flag is no-op in v0.1.0)
- Per-command `allowed-tools` hard enforcement (uses hook + skill prose instead — see [H2 Permission Compatibility Matrix](../../.deep-work/*/phase-2-plan.md))
- Cross-model verification via external Claude API (Gemini internal reviewers only)

### Known behavioral differences from CC

- **`MultiEdit` atomicity** — Gemini `replace` is single-pattern N-times; multi-pair edits require sequential calls (transactional pre-validation pattern)
- **Skill argument injection** — Gemini uses `postSubmitPrompt` (not `$ARGUMENTS`/`{{args}}` template placeholder)
- **Hook parallel execution** — Gemini fires same-event hooks in parallel (not sequentially like CC); PPID-keyed IPC cache still works via file write but is not relied upon for new design

See [../../docs/migration-from-claude-code.md](../../docs/migration-from-claude-code.md) for full differences.

### Build provenance

Ported via 10-slice Evidence-Driven Development (EDD) protocol on the CC plugin itself — Brainstorm → Research (v4 with Spike 0 source-level probe of Gemini CLI 0.35.0) → Plan (v3.1 after 3 review rounds with 13 cross-validated Critical findings) → Implement.
