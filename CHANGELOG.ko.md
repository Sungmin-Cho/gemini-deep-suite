# Changelog (모노레포)

[English](./CHANGELOG.md) | **한국어**

모노레포 전체 이벤트(스캐폴딩, 신규 패키지 추가, 인프라 변경)를 기록하는 최상위 changelog입니다.
패키지별 릴리스 노트는 `packages/<이름>/CHANGELOG.md`에 있습니다.

## [Unreleased]

(none)

## 2026-04-20 — 초기 스캐폴딩 + `deep-work v0.1.0`

### 추가
- 모노레포 스캐폴딩: `packages/`, `scripts/`, `docs/`, `.github/workflows/`
- `packages/deep-work/` — 첫 extension (v0.1.0), Claude Code `claude-deep-work v6.3.0` 포팅
  - 25개 skill (CC commands + skills 통합, `SkillCommandLoader`로 자동 등록)
  - Hook 시스템 (SessionStart, BeforeTool, AfterTool, SessionEnd) — 8개 mutating tool matcher
  - Sensors, health, templates 서브시스템
  - 557/557 테스트 통과
  - 상세: [packages/deep-work/CHANGELOG.md](./packages/deep-work/CHANGELOG.md) 참조
- 마이그레이션 도구 (`scripts/`):
  - `extract-hook-hardcodes.sh` — CC 특수 참조 자동 catalog
  - `migrate-skills.mjs` — CC command + skill body 변환기
  - `migrate-hooks.mjs` — CC hook → Gemini hook 자동 재작성
  - `publish-subtree.sh` — mirror push 수동 유틸리티
- CI/CD:
  - `.github/workflows/ci.yml` — 패키지별 validate + test
  - `.github/workflows/publish.yml` — tag 트리거 subtree split → mirror push
- 문서:
  - `README.md` + `README.ko.md` (이중 언어)
  - `CHANGELOG.md` + `CHANGELOG.ko.md` (이중 언어, 본 파일)
  - `docs/migration-from-claude-code.md` — CC와의 동작 차이
  - `docs/legacy/claude-deep-work/` — CC 설계 문서 참조용 아카이브

### 인프라
- **Mirror 배포 파이프라인 활성화**: `gemini-deep-suite` (개발) → `gemini-deep-work` (공개 설치 대상)
  - Deploy Key + `MIRROR_DEPLOY_KEY` secret 설정 완료
  - Tag 네이밍 규칙: `<패키지>-v<MAJOR>.<MINOR>.<PATCH>`
  - Tag push 시 자동 subtree split + force-with-lease push

### 리뷰 iteration
- Phase 1 Research: v4 (Spike 0에서 Gemini CLI 0.35.0 로컬 소스 probe)
- Phase 2 Plan: v3.1 (3 라운드 리뷰, 13 Critical 해결)
- Phase 3 Implement: 10 slice, migration script로 자동화
- Phase 4 Test: 557/557 pass, live hook enforcement 검증
- Post-commit 리뷰: 9 Critical + 14 Warning (Opus + Codex cross-validation), fix commit에서 처리
