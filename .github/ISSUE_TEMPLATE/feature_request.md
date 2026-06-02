---
name: ✨ 기능 / 씬·엔티티 추가
about: 새 게임 로직·시스템·아이소 씬·엔티티 추가나 기존 기능 개선을 제안합니다.
title: "feat: "
labels: ["enhancement"]
assignees: []
---

<!--
기획이 모호하면 구현 전에 무엇을 만들지부터 구체화하세요(Claude: superpowers:brainstorming).
이 템플릿은 AI가 곧장 TDD 루프로 들어갈 수 있을 만큼 "무엇을·왜·어디에·어떻게 검증"을 담는 데 목적이 있습니다.
해당 없는 섹션은 `N/A`.
-->

## 무엇을 만들까

<!-- 추가/개선할 기능을 2~4줄로. 사용자 관점에서 "무엇이 가능해지는가". -->

## 왜 필요한가 (동기)

<!-- 문제·목표. 이 템플릿(아이소 2D)의 맥락에서 어떤 가치가 있는가. -->

## 분류 <!-- 해당하는 것 체크 -->

- [ ] 게임 로직(전투·인벤토리 등) — 로직이면 **TDD + GdUnit4** 우선
- [ ] 새 아이소 씬 (World / GroundLayer / ObjectLayer / Camera2D 구조 — `/new-iso-scene`)
- [ ] 새 엔티티 (`src/entities/<이름>/` — `.tscn` ↔ `.gd` 동명 동폴더)
- [ ] 재사용 시스템 (`src/systems/`)
- [ ] Autoload 변경 (`EventBus` 시그널 추가 / `GameState` 상태) — 신중히
- [ ] 기존 기능 개선·확장

## 배치 위치 / 구조

<!--
AGENTS.md 디렉토리 규약을 따르세요.
- autoload → src/autoload/  |  재사용 시스템 → src/systems/  |  게임 객체 → src/entities/<이름>/
- 씬과 스크립트는 같은 폴더·같은 이름.
예상 파일·노드 트리를 적으세요.
-->

```text
(예: src/entities/enemy/enemy.gd, enemy.tscn / scenes/main.tscn > World/ObjectLayer 아래 배치)
```

## 동작 명세 / 수용 시나리오

<!-- "이렇게 입력하면 이렇게 동작한다"를 구체적으로. TDD라면 이게 곧 테스트 케이스가 됩니다. -->

- 시나리오 1:
- 시나리오 2:

## 시그널·상태 설계 <!-- 노드 간 결합이 생기면. 아니면 N/A -->

<!-- "아래로 호출, 위로 시그널". 직접 참조 대신 EventBus 시그널 우선. -->

- **추가할 EventBus 시그널**: <!-- 예: `signal enemy_defeated(enemy)` — snake_case 과거형 -->
- **GameState 변경**: <!-- 점수/상태 등 -->

## 🤖 AI 작업 계획 <!-- AI가 작성 중이면. 아니면 N/A -->

- **쓸 스킬·도구**: <!-- godot-isometric / gdunit4-testing / new-iso-scene / context7 / godot MCP 등 -->
- **확인이 필요한 API**: <!-- context7로 검증할 Godot API. 추측 금지 -->
- **불확실·결정 필요 지점**: <!-- 사람 판단이 필요한 설계 선택 -->

## ✅ 완료 조건(Acceptance)

- [ ] <!-- 예: enemy가 Player를 추적하고 충돌 시 EventBus.enemy_collided 발생 -->
- [ ] 새 로직에 GdUnit4 테스트 추가 (`/godot-test` 통과)
- [ ] `/godot-run` 실행 시 parse/import 에러 없음
- [ ] 네이밍·정적 타이핑·멤버 순서가 `docs/GODOT_CONVENTIONS.md`를 따른다

## 범위 밖 / 비목표

<!-- 이 이슈에서 다루지 않을 것. 스코프 확산 방지. -->
