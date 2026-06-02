---
name: 📝 문서 / 규약 개선
about: AGENTS.md·docs/·스킬·CLAUDE.md 등 지침/규약이 틀렸거나, 모호하거나, 보강이 필요할 때 사용합니다.
title: "docs: "
labels: ["documentation"]
assignees: []
---

<!--
이 레포에서 문서·규약은 "여러 AI 에이전트가 공유하는 정본 지식"입니다.
지침이 틀리거나 모호하면 모든 에이전트의 작업 품질이 떨어집니다.
어디가/왜 문제이고 어떻게 고쳐야 하는지 구체적으로 적으세요.
-->

## 대상 문서 <!-- 해당하는 것 체크 -->

- [ ] `AGENTS.md` (도구 무관 정본 지침)
- [ ] `docs/SETUP.md`
- [ ] `docs/ARCHITECTURE.md`
- [ ] `docs/GODOT_CONVENTIONS.md`
- [ ] `docs/COMMIT_CONVENTIONS.md`
- [ ] `.claude/CLAUDE.md` / `.claude/agents/` (Claude 전용)
- [ ] 공용 스킬 `skills/<이름>/SKILL.md`
- [ ] `README.md`
- [ ] 기타: <!-- 경로 -->

## 문제 유형

- [ ] **부정확** — 사실/코드와 다름 (예: 시그니처·경로·노드 트리 불일치)
- [ ] **모호** — 해석이 갈려 에이전트마다 다르게 행동
- [ ] **누락** — 있어야 할 지침/예시가 없음
- [ ] **구식** — Godot 버전 변화 등으로 더 이상 유효하지 않음(예: deprecated API)
- [ ] **불일치** — 문서 간(예: AGENTS.md ↔ docs/) 또는 도구 간(Claude ↔ Codex) 내용이 어긋남

## 현재 내용

<!-- 문제가 되는 부분을 파일·줄과 함께 그대로 인용. -->

> 파일: `경로:줄번호`
>
> (현재 서술 인용)

## 무엇이 문제인가

<!-- 왜 틀렸/모호/부족한지. 코드나 공식 문서와 어떻게 다른지. -->

## 제안하는 수정

<!-- 어떻게 바꿀지. 가능하면 수정 후 문구를 그대로 제시. -->

```text
(수정 후 제안 문구)
```

## 근거 / 공식 문서

<!--
규약·API 관련이면 추측하지 말고 근거를 대세요(AGENTS.md 원칙).
- Godot: context7 `/godotengine/godot-docs`
- 실제 코드: 관련 src/ 파일 인용
-->

- **참조**:

## 파급 영향

- [ ] **도구 간 일관성** — Claude·Codex 양쪽 지침/스킬에 같은 변경이 필요한가
- [ ] **다른 문서 동기화** — 같은 내용을 다루는 다른 파일(AGENTS.md ↔ docs/ ↔ SKILL.md)도 함께 고쳐야 하는가

## ✅ 완료 조건(Acceptance)

- [ ] <!-- 예: AGENTS.md와 docs/GODOT_CONVENTIONS.md의 멤버 순서 서술이 일치한다 -->
- [ ] <!-- 예: 관련 스킬 SKILL.md도 동일하게 갱신했다 -->
