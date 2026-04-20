# GEMINI.md — gemini-deep-suite

Instructions for Gemini CLI (and compatible agents) working in this repo. Concise table-of-contents style.

## 1. Project identity

- **Name**: `gemini-deep-suite` — Gemini CLI extension monorepo
- **Origin**: Port of Claude Code plugin [`claude-deep-work v6.3.0`](https://github.com/Sungmin-Cho/claude-deep-work)
- **Current version**: `deep-work v0.1.0` (first extension, solo-mode)

## 2. Monorepo layout

```
gemini-deep-suite/
├── packages/
│   └── deep-work/           # ✅ v0.1.0 shipped (mirror: gemini-deep-work)
│       ├── gemini-extension.json
│       ├── GEMINI.md        # extension-level context (auto-loaded by Gemini)
│       ├── skills/          # 25 skills (auto-registered via SkillCommandLoader)
│       ├── hooks/           # 4 events × 8 mutating-tool matcher
│       ├── sensors/, health/, templates/
│       └── assumptions.json
├── scripts/                 # migration + publish utilities
├── docs/                    # migration guide + legacy archive
├── .github/workflows/       # ci.yml, publish.yml
└── GEMINI.md (this file), README.md (+ .ko), CHANGELOG.md (+ .ko), LICENSE
```

## 3. 🔴 Mirror publish rules (critical)

Gemini CLI's `extensions install` requires `gemini-extension.json` at the repo root, so monorepo subdirectories cannot be installed directly. **Subtree split to a mirror repo is mandatory.**

### Repo topology

| Repo | Role | Push access |
|---|---|---|
| `gemini-deep-suite` | Development (monorepo) | Direct push |
| `gemini-deep-work` | **Mirror** — `packages/deep-work/` contents only | **Do NOT push manually** — only `publish.yml` workflow |

### Automated release (recommended)

```bash
# Tag push → automatic mirror update
git tag deep-work-v0.1.1
git push origin deep-work-v0.1.1
# → .github/workflows/publish.yml auto-triggers:
#   1. git subtree split -P packages/deep-work -b publish/deep-work
#   2. git push mirror-deep-work publish/deep-work:main --force-with-lease
#   3. Tag v0.1.1 created on mirror repo
```

### Tag naming

`<package>-v<MAJOR>.<MINOR>.<PATCH>` — e.g. `deep-work-v0.1.0`, (future) `deep-wiki-v0.2.0`.

### Manual fallback

```bash
./scripts/publish-subtree.sh deep-work v0.1.1
```

### 🚨 Strictly forbidden

- **Direct commit/push to mirror repo** — subtree split uses `--force-with-lease` and will overwrite
- **Modifying Deploy Key or `MIRROR_DEPLOY_KEY` secret** — required by GitHub Actions
- **Renaming `packages/deep-work/` path** — hardcoded in `publish-subtree.sh` and `publish.yml`

## 4. Development workflow

### Local development

```bash
# Link (symlink — changes reflected immediately)
gemini extensions link --consent packages/deep-work

# Validate
gemini extensions validate packages/deep-work

# Run tests (all subsystems)
cd packages/deep-work && node --test    # 557 tests
```

### Refreshing the linked extension

```bash
gemini extensions uninstall deep-work
gemini extensions link --consent packages/deep-work
```

## 5. Migration tooling (`scripts/`)

| Script | Purpose |
|---|---|
| `extract-hook-hardcodes.sh` | Automated 3-axis catalog of CC-specific refs (`.claude/`, tool names, abs paths) |
| `migrate-skills.mjs` | CC commands + skills → Gemini skill body (Skill/Agent/AskUser → natural language) |
| `migrate-hooks.mjs` | CC hooks → Gemini hooks (stdin parser injection, tool rename, path rewrite) |
| `publish-subtree.sh` | Manual mirror push (local test or fallback to auto workflow) |

## 6. Architectural invariants

### State namespace

- Runtime state: **`.gemini/deep-work/`** or **`.gemini/deep-work.<SESSION_ID>.md`**
- CC `.claude/` paths are **legacy fallback only** (`utils.sh::find_project_root`)
- **Hybrid CC + Gemini support**: prefer `.gemini/`, fall back to `.claude/`

### Hook protocol

- Block decision: **`exit 0 + stdout JSON {decision:"deny", reason}`** (Gemini idiomatic)
- `exit 2 + stderr` is emergency brake fallback (stdout JSON not parsed)
- stdin JSON: `{session_id, transcript_path, cwd, hook_event_name, timestamp, tool_name, tool_input}`

### Skill patterns

- **Do not use `{{args}}` in skill bodies** (TOML command only)
- Arguments auto-injected via **`postSubmitPrompt`** — reference in natural language (`"the user's task input"`)
- **Ignore Team mode / `TeamCreate` directives** — v0.1.0 is solo-only (scope revision)

### Tool name mapping

| CC | Gemini |
|---|---|
| `Write` | `write_file` |
| `Edit`/`MultiEdit` | `replace` (atomic MultiEdit uses transactional pre-validation) |
| `Bash` | `run_shell_command` |
| `Read`/`Glob`/`Grep` | `read_file`/`glob`/`grep_search` |
| `AskUserQuestion` | `ask_user` |
| `TaskCreate/Update/List/Get` | `tracker_create_task/update_task/list_tasks/get_task` |
| `NotebookEdit` | (unsupported) — fall back to `write_file` |

## 7. Testing rules

- `node --test` (Node native runner, no framework)
- **Every PR must keep 557/557 passing** (no regressions)
- Test fixtures use Gemini stdin envelope (`{tool_name, tool_input}` shape)
- Do not add new fixtures in CC style (`CLAUDE_TOOL_USE_TOOL_NAME` env)

## 8. Documentation index

| Document | Purpose |
|---|---|
| [`packages/deep-work/GEMINI.md`](packages/deep-work/GEMINI.md) | Extension user guide (auto-loaded by Gemini when extension installed) |
| [`packages/deep-work/CHANGELOG.md`](packages/deep-work/CHANGELOG.md) | Per-package release notes |
| [`packages/deep-work/README.md`](packages/deep-work/README.md) | Extension install + usage |
| [`docs/migration-from-claude-code.md`](docs/migration-from-claude-code.md) | CC → Gemini behavioral differences |
| [`docs/legacy/claude-deep-work/`](docs/legacy/claude-deep-work/) | Original CC design docs (reference only) |
| [`README.md`](README.md) / [`README.ko.md`](README.ko.md) | Monorepo overview (bilingual) |
| [`CHANGELOG.md`](CHANGELOG.md) / [`CHANGELOG.ko.md`](CHANGELOG.ko.md) | Monorepo-level changelog (bilingual) |

## 9. v0.2.0+ roadmap (scope revision record)

- Team mode (pending Gemini subagent parallel verification)
- Remaining 5 plugins ported sequentially: `deep-wiki` → `deep-evolve` → `deep-review` → `deep-docs` → `deep-dashboard`
- npm publish (currently GitHub install only)
- Windows native support (currently WSL recommended)

## 10. Contribution rules

- **Commit messages**: Conventional Commits (`feat:`, `fix:`, `docs:`, ...); include rationale/evidence in body
- **When modifying `packages/deep-work/`**: Re-run all 557 tests
- **When modifying hooks/scripts**: Run `scripts/extract-hook-hardcodes.sh` to catch residual `.claude/` literals
- **When adding features**: Update both `packages/deep-work/CHANGELOG.md` and `docs/migration-from-claude-code.md` (behavior diffs)
- **Breaking changes**: Bump major version tag (`deep-work-v1.0.0`) and update migration guide

## Note

`CLAUDE.md` is gitignored (machine-local agent instructions for Claude). This `GEMINI.md` is the tracked/pushed counterpart for Gemini-based contributors.
