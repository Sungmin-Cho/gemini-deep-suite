# gemini-deep-suite

**English** | [한국어](./README.ko.md)

Gemini CLI extensions for Evidence-Driven Development, ported from [claude-deep-suite](https://github.com/Sungmin-Cho/claude-deep-suite).

## Status

**v0.1.0** (in development) — initial port of `deep-work` plugin only. Other plugins (deep-wiki, deep-evolve, deep-review, deep-docs, deep-dashboard) will follow.

## Extensions

| Extension | Version | Description |
|---|---|---|
| [deep-work](./packages/deep-work) | 0.1.0 | Evidence-Driven Development Protocol — Brainstorm → Research → Plan → Implement → Test auto-flow |

## Installation

Each extension is published as a separate mirror repository. Install via:

```bash
gemini extensions install https://github.com/sungmin-cho/gemini-deep-work
```

See each `packages/<name>/README.md` for extension-specific guides.

## Behavioral differences from Claude Code version

See [docs/migration-from-claude-code.md](./docs/migration-from-claude-code.md).

Key v0.1.0 limitations:
- **Solo mode only** — Team mode (parallel subagent dispatch) deferred to v0.2.0+
- **MultiEdit atomicity** — Gemini `replace` is not atomic across multiple edit pairs; uses transactional pre-validation pattern
- **Per-command tool gates** — Gemini has no direct equivalent of Claude Code's `allowed-tools` frontmatter; uses hook enforcement + skill body prose (soft rule)

## Monorepo structure

```
gemini-deep-suite/
├── packages/           Extension packages (published via subtree split)
├── scripts/            Migration + publish utilities
├── docs/
│   ├── legacy/         Original Claude Code plugin docs (reference only)
│   └── migration-from-claude-code.md
├── .github/workflows/  CI + subtree publish
└── .gitignore
```

## Development

```bash
# Validate local extension
gemini extensions validate packages/deep-work

# Link for local testing
gemini extensions link --consent packages/deep-work
```

## Publish pipeline

Tag push (`deep-work-v0.1.0`) → GitHub Actions `publish.yml` → git subtree split → push to `gemini-deep-work` mirror repo.

## License

MIT — see [LICENSE](./LICENSE).
