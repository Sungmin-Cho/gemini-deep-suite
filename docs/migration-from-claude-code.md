# Migration from Claude Code deep-work

**Target**: Users familiar with [`claude-deep-work`](https://github.com/Sungmin-Cho/claude-deep-work) v6.3.0 migrating to Gemini CLI.

## v0.1.0 Behavioral Differences

### 1. Runtime state namespace

CC uses `.claude/deep-work.{SESSION_ID}.md` for session state. Gemini port uses **`.gemini/deep-work.{SESSION_ID}.md`** to avoid namespace collision if you use both tools in the same repo.

Legacy migration: A future helper `/dw-migrate` slash command (planned v0.1.1) will convert CC state files to Gemini layout.

### 2. Slash commands → Agent Skills

CC has separate commands (`commands/*.md`) and skills (`skills/<name>/SKILL.md`). Gemini consolidates both: **each CC command body becomes a Gemini skill**. Skills auto-register as slash commands via Gemini's `SkillCommandLoader`, so `/deep-work`, `/deep-brainstorm`, etc. work as expected.

Internal change: CC `Skill("deep-X", args="$ARGUMENTS")` invocations in command bodies are replaced with natural-language instructions (`"invoke /deep-X"`) that Gemini's LLM executes in-turn. Empirically verified (Slice 0 spike): single `/deep-work` invocation chains phase skills in one response.

### 3. Arguments in skill bodies

CC skills use `$ARGUMENTS` placeholder. Gemini skills receive args via `postSubmitPrompt` **after** body injection, NOT as a template placeholder. Skill bodies must reference args in natural language ("the user's task input will follow this body") rather than `{{args}}` or `$ARGUMENTS`.

### 4. Team mode — **deferred to v0.2.0**

CC supports parallel subagent dispatch via `TeamCreate`/`SendMessage`. Gemini subagent parallel execution is not verified in Gemini CLI 0.35.0 public docs as of this release. v0.1.0 is **solo-mode only**; `--team` flag is a no-op.

### 5. MultiEdit — transactional pre-validation

CC has `MultiEdit` for atomic multi-pair edits in a single tool call. Gemini's `replace` tool is **single pattern N-times** (via `allow_multiple: true`), which is not equivalent. v0.1.0 uses a **transactional pre-validation pattern**:

1. Pre-flight: verify all intended (old, new) pairs have exactly 1 match in target file
2. If all pass: invoke `replace` N times sequentially
3. If any pre-flight fails: abort without any write

This preserves "all or nothing" semantics but adds a validation pass. Performance impact: negligible (<10ms typical).

### 6. Per-command `allowed-tools` → hook enforcement + skill prose

CC commands have `allowed-tools` frontmatter to restrict tools per command (e.g., `/deep-assumptions` allows only `Read`). Gemini has no equivalent primitive. Port uses:

- **Hook enforcement (hard)**: `phase-guard` BeforeTool hook rejects tool calls based on current phase + tool name
- **Skill body prose (soft)**: Each skill body names allowed tools; LLM usually respects this but is not hard-enforced

This may produce occasional tool-usage drift if the LLM ignores skill prose. Measured by hook rejection rate in Slice 8 E2E.

### 7. Hook event mapping

| CC | Gemini |
|---|---|
| SessionStart | SessionStart |
| PreToolUse | BeforeTool |
| PostToolUse | AfterTool |
| Stop | SessionEnd |

CC hook environment variables (`CLAUDE_TOOL_USE_TOOL_NAME`, `CLAUDE_TOOL_NAME`, `CLAUDE_TOOL_USE_INPUT`) are replaced by Gemini's stdin JSON (`{tool_name, tool_input, ...}`). Migration script `scripts/extract-hook-hardcodes.sh` catalogs all CC-specific references.

### 8. Block decision protocol

CC's `phase-guard.sh` uses `stdout JSON + exit 2`. Gemini interprets `exit 2 → stderr as rejection reason; stdout must be JSON only`. Port uses **`exit 0 + JSON stdout`** (idiomatic in Gemini) for all block decisions.

### 9. Absolute path hardcodes

CC phase-guard allowlists `~/.claude/plugins/cache/claude-deep-suite/deep-work/*/skills/deep-integrate/phase5-finalize.sh` (plugin install path). Gemini port uses `${extensionPath}/skills/deep-integrate/phase5-finalize.sh` + canonical realpath check to prevent symlink spoofing.

## Platform support

| Platform | v0.1.0 |
|---|---|
| macOS | ✅ |
| Linux | ✅ |
| Windows native | ❌ — bash dependency |
| Windows WSL | ✅ |

## FAQ

**Q: Can I use CC `deep-work` and Gemini `deep-work` in the same repo?**
A: Yes, since Gemini port uses `.gemini/deep-work/` namespace. State files don't collide.

**Q: Does `/deep-work` auto-flow all 5 phases?**
A: Yes, empirically verified (Slice 0). Each phase transition asks `ask_user("proceed?")` and waits for user turn — not fully headless.

**Q: What if Gemini model rate-limits mid-session?**
A: State file is preserved. Resume via `/deep-resume`.
