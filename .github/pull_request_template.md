<!--
이 레포는 대부분의 변경을 AI(Claude Code)가 작성합니다.
따라서 이 템플릿은 "무엇을 바꿨나"보다 "어떻게 검증했고, 사람이 어디를 봐야 하나"에 무게를 둡니다.
해당 없는 섹션은 지우지 말고 `N/A`로 표시하세요. 체크박스는 실제로 한 것만 체크합니다.
-->

## 요약

<!-- 무엇을, 왜 바꿨는지 2~4줄. 코드 디프로 알 수 있는 세부는 생략. -->

## 변경 유형

- [ ] `feat` 기능 추가
- [ ] `fix` 버그 수정
- [ ] `refactor` 동작 변화 없는 구조 개선
- [ ] `docs` 문서/주석
- [ ] `test` 테스트 추가·수정
- [ ] `chore` 설정·빌드·툴링

## 맥락 / 관련 이슈

<!-- Closes #이슈번호. 작업 지시의 출처(이슈, 대화, 기획 문서 등)와 배경. -->

---

## 🤖 AI 작업 정보

<!-- 이 PR을 AI가 작성했다면 채웁니다. 사람이 직접 작성했다면 "사람 작성"이라고만 적고 아래는 N/A. -->

- **작성 주체**: <!-- 예: Claude Code (Opus 4.x) / 사람 / 혼합 -->
- **사용한 스킬·도구**: <!-- 아래에서 실제 쓴 것만 남기세요 -->
  - [ ] `superpowers:brainstorming` (기획 구체화)
  - [ ] `superpowers:systematic-debugging` (버그 원인 추적)
  - [ ] `superpowers:test-driven-development` (테스트 우선)
  - [ ] `context7` MCP — Godot API를 추측 대신 `/godotengine/godot-docs`로 확인
  - [ ] `godot` MCP — 에디터/씬/노드 조작·실행·디버그 캡처
  - [ ] `godot-gdscript-patterns` (GDScript 패턴 — game-development 플러그인 스킬, 로컬 `skills/` 아님)
  - [ ] `godot-isometric` / `gdunit4-testing` / `godot-project-conventions`
- **핵심 의사결정**: <!-- 왜 이 방식을 골랐는지. 대안과 트레이드오프가 있었다면 한 줄. -->

## 🔎 사람이 집중 리뷰할 곳 (필수)

<!-- AI가 작성한 코드는 그럴듯해 보여도 틀릴 수 있습니다. 리뷰어의 눈이 가장 필요한 곳을 콕 집어주세요. -->

- **확신이 낮거나 추측이 들어간 부분**: <!-- 예: ObjectLayer Y-sort origin 값, 충돌 레이어 마스크 -->
- **부수효과·영향 범위**: <!-- 시그널 추가/변경, autoload 상태 변경, 입력맵 변경 등 다른 씬에 미치는 영향 -->
- **검증으로 못 잡는 부분**: <!-- 디자인 의도, 밸런스, 시각적 느낌 등 사람 판단이 필요한 것 -->

---

## ✅ 검증 (verification-before-completion)

<!-- "검증 없이 완료라고 하지 않는다" — CLAUDE.md 원칙. 실제로 돌려보고 체크하세요. -->

- [ ] Godot **4.4+** 에디터에서 프로젝트가 열리고 **parse / import 에러 없음**
- [ ] Smoke: `godot --headless --path . --quit-after 10` 또는 `/godot-run` 실행 — 콘솔에 `SCRIPT ERROR` / `Parse error` / `ext_resource ... not found` 없음
- [ ] Unit: `/godot-test` (GdUnit4) 통과 <!-- addons/gdUnit4 설치 시 필수. 미설치면 체크하지 말고 아래 검증 증거에 "GdUnit4 미설치로 미실행"과 확인 명령을 적는다. -->
- [ ] 새/변경된 로직에 대한 **테스트를 추가**했다 (또는 사유 기재)
- [ ] (씬·스크립트 변경 시) 영향받는 다른 씬도 실행해 회귀 없음을 확인

**검증 증거** <!-- 실행 로그·테스트 출력·스크린샷/영상. AI 작업일수록 증거가 신뢰를 만듭니다. -->

```text
(여기에 /godot-test 결과나 실행 로그를 붙여넣기)
```

## 🧭 아이소메트릭 체크 <!-- 좌표/렌더링을 건드렸을 때만. 아니면 N/A -->

- [ ] 셀↔픽셀 변환은 런타임에 `TileMapLayer.local_to_map()` / `map_to_local()`를 사용했다 (전역좌표는 `to_local()` 선처리)
- [ ] Y-sort 대상은 같은 `y_sort_enabled` 부모 아래 있고, Y-sort/비-Y-sort 레이어의 `z_index`가 분리돼 있다
- [ ] 캐릭터가 바닥/오브젝트 뒤·앞으로 올바르게 가려진다 (정렬 어긋남 없음)

## 📐 규약 준수

- [ ] 네이밍: 파일 `snake_case` / `class_name` PascalCase / 노드 PascalCase / 시그널 `snake_case` 과거형 / private `_` 접두
- [ ] 노드 간 결합은 직접 참조 대신 **`EventBus` 시그널** 우선, 전역 상태는 **`GameState`** 경유
- [ ] 변수·인자·반환에 **정적 타입** 명시 (`get_node()` 결과는 타입 명시)
- [ ] **멤버 순서·포매팅**이 `docs/GODOT_CONVENTIONS.md`(공식 GDScript 스타일 가이드)를 따른다
- [ ] Godot API는 추측하지 않고 `context7`로 확인했다
- [ ] 커밋 메시지가 `docs/COMMIT_CONVENTIONS.md`를 따른다 — **AI attribution(`Co-Authored-By` 등) 없음**, `<type>(<scope>): <제목>` 형식, 변경사항만 간결히

## 📸 스크린샷 / 영상 <!-- 시각·동작 변화가 있으면. 없으면 N/A -->

## 후속 작업 / 남은 일

<!-- 이 PR 범위 밖이지만 이어서 해야 할 것. 없으면 "없음". -->
