# gemini-deep-suite

[English](./README.md) | **한국어**

Evidence-Driven Development(증거 기반 개발)를 위한 Gemini CLI extension 모음. [claude-deep-suite](https://github.com/Sungmin-Cho/claude-deep-suite)에서 포팅됨.

## 현재 상태

**v0.1.0** (개발 중) — `deep-work` 플러그인 최초 포팅. 나머지 플러그인(deep-wiki, deep-evolve, deep-review, deep-docs, deep-dashboard)은 순차 진행 예정.

## Extensions

| Extension | Version | 설명 |
|---|---|---|
| [deep-work](./packages/deep-work) | 0.1.0 | Evidence-Driven Development Protocol — Brainstorm → Research → Plan → Implement → Test 자동 흐름 |

## 설치

각 extension은 별도 mirror repo로 배포됩니다:

```bash
gemini extensions install https://github.com/sungmin-cho/gemini-deep-work
```

extension별 상세 가이드는 `packages/<이름>/README.md` 참조.

## Claude Code 원본과의 동작 차이

[docs/migration-from-claude-code.md](./docs/migration-from-claude-code.md) 참조.

v0.1.0 주요 제한:
- **Solo 모드 전용** — Team 모드(subagent 병렬 dispatch)는 v0.2.0 이후
- **MultiEdit 원자성** — Gemini `replace`는 여러 edit 쌍에 atomic하지 않음. transactional pre-validation 패턴 사용
- **Per-command tool 게이트** — Gemini는 Claude Code의 `allowed-tools` frontmatter에 직접 대응되는 primitive가 없음. hook enforcement + skill body 지시로 부분 대체(soft rule)

## 모노레포 구조

```
gemini-deep-suite/
├── packages/           Extension 패키지 (subtree split으로 배포)
├── scripts/            마이그레이션 + 배포 유틸리티
├── docs/
│   ├── legacy/         원본 Claude Code 플러그인 문서 (참조 전용)
│   └── migration-from-claude-code.md
├── .github/workflows/  CI + subtree publish
└── .gitignore
```

## 개발

```bash
# 로컬 extension 유효성 검사
gemini extensions validate packages/deep-work

# 로컬 테스트용 링크
gemini extensions link --consent packages/deep-work
```

## 배포 파이프라인

Tag push (`deep-work-v0.1.0`) → GitHub Actions `publish.yml` → git subtree split → `gemini-deep-work` mirror repo로 push.

## 라이선스

MIT — [LICENSE](./LICENSE) 참조.
