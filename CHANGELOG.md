# Changelog (monorepo)

**English** | [한국어](./CHANGELOG.ko.md)

Top-level changelog tracking monorepo-wide events (scaffolding, new packages, infra changes).
Per-package release notes live at `packages/<name>/CHANGELOG.md`.

## [Unreleased]

(none)

## 2026-04-20 — Initial scaffolding + `deep-work v0.1.0`

### Added
- Monorepo scaffolding: `packages/`, `scripts/`, `docs/`, `.github/workflows/`
- `packages/deep-work/` — first extension (v0.1.0), port of Claude Code `claude-deep-work v6.3.0`
  - 25 skills (CC commands + skills consolidated via `SkillCommandLoader`)
  - Hook system (SessionStart, BeforeTool, AfterTool, SessionEnd) with 8-tool matcher
  - Sensors, health, templates subsystems
  - 557/557 tests passing
  - See [packages/deep-work/CHANGELOG.md](./packages/deep-work/CHANGELOG.md) for details
- Migration tooling (`scripts/`):
  - `extract-hook-hardcodes.sh` — automated catalog of CC-specific references
  - `migrate-skills.mjs` — CC command + skill body transformer
  - `migrate-hooks.mjs` — CC hook → Gemini hook automated rewrite
  - `publish-subtree.sh` — manual mirror push utility
- CI/CD:
  - `.github/workflows/ci.yml` — per-package validate + test
  - `.github/workflows/publish.yml` — tag-triggered subtree split → mirror push
- Documentation:
  - `README.md` + `README.ko.md` (bilingual)
  - `CHANGELOG.md` + `CHANGELOG.ko.md` (bilingual, this file)
  - `docs/migration-from-claude-code.md` — behavioral differences from CC
  - `docs/legacy/claude-deep-work/` — reference archive of CC design docs

### Infrastructure
- **Mirror publish pipeline activated**: `gemini-deep-suite` (dev) → `gemini-deep-work` (public install target)
  - Deploy Key + `MIRROR_DEPLOY_KEY` secret configured
  - Tag convention: `<package>-v<MAJOR>.<MINOR>.<PATCH>`
  - Tag push triggers automated subtree split + force-with-lease push

### Review iterations
- Phase 1 Research: v4 (Spike 0 local-source probe of Gemini CLI 0.35.0)
- Phase 2 Plan: v3.1 (3 review rounds, 13 Critical resolved)
- Phase 3 Implement: 10 slices, automated via migration scripts
- Phase 4 Test: 557/557 pass, live hook enforcement verified
- Post-commit review: 9 Critical + 14 Warning (Opus + Codex cross-validation), addressed in fix commit
