---
name: 🐞 버그 리포트
about: 실행·테스트 중 발생한 오류나 잘못된 동작(특히 Y-sort·좌표 변환·parse/import 에러)을 보고합니다.
title: "fix: "
labels: ["bug"]
assignees: []
---

<!--
이 레포는 대부분 AI(Claude Code·Codex)가 이슈를 작성·처리합니다.
따라서 이 템플릿은 "증상"뿐 아니라 "재현 절차·환경·증거"를 충분히 담아
다른 에이전트나 사람이 추가 질문 없이 곧장 디버깅을 시작할 수 있게 하는 데 목적이 있습니다.
해당 없는 섹션은 지우지 말고 `N/A`로 두세요. 추측은 [추측]이라고 표시하세요.
-->

## 요약

<!-- 무엇이 잘못됐는지 1~3줄. 예: "Player가 ObjectLayer 타일 뒤로 가도 앞에 그려진다(Y-sort 어긋남)." -->

## 재현 절차

<!-- 다른 사람이 그대로 따라 할 수 있게 번호로. 어떤 씬/스크립트/입력인지 명확히. -->

1.
2.
3.

## 기대한 동작

<!-- 정상이라면 어떻게 됐어야 하는가. -->

## 실제 동작

<!-- 실제로 무슨 일이 일어났는가. -->

## 콘솔 / 에러 로그

<!--
`/godot-run`(또는 에디터 F5) 콘솔 출력을 그대로 붙여넣으세요.
특히 다음을 빠짐없이: SCRIPT ERROR / Parse error / ext_resource ... not found / Invalid get index / Null instance
-->

```text
(여기에 콘솔·에러 로그를 붙여넣기)
```

## 환경

<!-- 추측하지 말고 실제 값을 적으세요. Godot 버전은 `godot --version` 또는 에디터 About에서 확인. -->

- **Godot 버전**: <!-- 예: 4.4.1 stable -->
- **렌더러**: <!-- GL Compatibility (기본) / 기타 -->
- **OS**: <!-- macOS 15 / Windows 11 / Linux -->
- **에이전트·도구**: <!-- Claude Code / Codex / 사람. godot·context7 MCP 연결 여부 -->
- **관련 파일·씬·노드**: <!-- 예: src/entities/player/player.gd, scenes/main.tscn > World/ObjectLayer -->

## 🧭 아이소메트릭 의심 지점 <!-- 좌표/렌더링/정렬 버그일 때만. 아니면 N/A -->

<!-- docs/GODOT_CONVENTIONS.md + iso-debug 절차 기준의 자가 점검. 해당하면 체크. -->

- [ ] 셀↔픽셀 변환에 `local_to_map(to_local(global_pos))` 대신 전역 좌표를 바로 넘기고 있다
- [ ] Y-sort 대상이 `y_sort_enabled=true` 부모 아래에 있지 않다
- [ ] Y-sort 레이어와 비-Y-sort 레이어의 `z_index`가 분리돼 있지 않다(한 덩어리로 섞임)
- [ ] `TileMapLayer.y_sort_origin` 오프셋이 타일 기준점과 안 맞는다
- [ ] (4.3+에서) deprecated된 `TileMap` 노드를 쓰고 있다

## 🤖 AI 1차 진단 <!-- AI가 작성 중이라면 채우세요. 사람이면 N/A -->

- **추정 원인**: <!-- 근거와 함께. 확신이 낮으면 [추측] 표시 -->
- **확인에 쓴 근거·도구**: <!-- 예: context7 /godotengine/godot-docs에서 local_to_map 시그니처 확인, godot MCP 디버그 캡처 -->
- **제안 수정 방향**: <!-- 어떻게 고칠지 한두 줄. 아직 모르면 "조사 필요" -->

## 영향 범위 / 심각도

- **심각도**: <!-- blocker(실행 불가) / major(핵심 기능 깨짐) / minor(부분 문제) / trivial -->
- **영향받는 다른 씬·시스템**: <!-- EventBus 시그널, GameState 상태, 입력맵 등 파급 -->

## ✅ 완료 조건(Acceptance)

<!-- 이 이슈가 닫히려면 무엇이 참이어야 하는가. 검증 가능하게. -->

- [ ] <!-- 예: main.tscn 실행 시 콘솔에 에러 없음 -->
- [ ] <!-- 예: Player가 오브젝트 앞/뒤로 올바르게 가려진다 -->
- [ ] <!-- 예: 회귀 방지용 GdUnit4 테스트 추가 -->
