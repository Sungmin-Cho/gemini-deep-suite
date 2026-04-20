# deep-work (Gemini CLI edition)

Evidence-Driven Development Protocol extension for Gemini CLI. `/deep-work "task"` automates Brainstorm → Research → Plan → Implement → Test.

## Installation

```bash
gemini extensions install https://github.com/sungmin-cho/gemini-deep-work
```

Or for development:
```bash
git clone https://github.com/sungmin-cho/gemini-deep-suite
cd gemini-deep-suite
gemini extensions link --consent packages/deep-work
```

## Usage

```bash
gemini
# /deep-work "Add user authentication to my Next.js app"
```

The orchestrator skill guides you through 5 phases. Each transition asks `"진행?"` — confirm to continue or use `/deep-status` to check state.

## Commands (slash)

All are Gemini **skills** — invoke via slash. See `skills/<name>/SKILL.md` for each body.

Phase skills: `/deep-work`, `/deep-brainstorm`, `/deep-research`, `/deep-plan`, `/deep-implement`, `/deep-test`, `/deep-integrate`

Session skills: `/deep-status`, `/deep-finish`, `/deep-fork`, `/deep-history`, `/deep-resume`, `/deep-cleanup`, `/deep-debug`

Analysis skills: `/deep-assumptions`, `/deep-insight`, `/deep-mutation-test`, `/deep-phase-review`, `/deep-receipt`, `/deep-report`, `/deep-sensor-scan`, `/deep-slice`, `/drift-check`, `/solid-review`

## Differences from Claude Code version

See [migration guide](../../docs/migration-from-claude-code.md).

Key: solo mode only, `.gemini/deep-work/` namespace, transactional MultiEdit, hook+prose enforcement.

## License

MIT
