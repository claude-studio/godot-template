---
name: iso-debug
description: 아이소메트릭 특유의 버그(Y-sort 어긋남, 좌표 변환 오류, 클릭 셀 불일치)를 체계적으로 디버깅한다. systematic-debugging + godot-isometric 스킬 + context7 확인 + godot MCP 디버그 캡처를 단계별로 진행한다. /iso-debug 로 호출.
allowed-tools: Read, Edit, Bash, Grep, Glob
---

# /iso-debug — 아이소 Y-sort·좌표 변환 디버깅

아이소메트릭 2D에서만 나타나는 증상을 추측 없이 단계적으로 좁힌다. 흔한 증상은 두 가지다.

- **Y-sort 어긋남**: 뒤 오브젝트가 앞 오브젝트를 가리거나, 캐릭터가 가구 뒤로/앞으로 잘못 그려짐.
- **좌표 변환 오류**: 마우스로 클릭한 위치와 보고되는 셀 좌표가 안 맞음, 또는 논리 그리드 ↔ 스크린 변환 결과가 어긋남.

## 0단계 — 디버깅 프레임 진입

`superpowers:systematic-debugging` 스킬로 시작한다. 증상을 한 문장으로 정의하고, 추측으로 코드를 고치기 전에 **가설 → 관찰 → 검증** 루프를 잡는다. 동시에 `godot-isometric` 스킬을 읽어 이 템플릿의 좌표·Y-sort 규약을 기준값으로 확보한다.

## 1단계 — 증상 재현 및 관찰 (godot MCP)

godot MCP가 활성이면 그 디버그 출력 캡처를 우선 사용한다(없으면 `godot-run` 스킬의 CLI로 실행 후 stdout 관찰).

1. godot MCP로 문제 씬을 실행한다(프로젝트 실행 또는 씬 실행 도구).
2. 디버그 출력 캡처 도구(예: `get_debug_output`)로 stdout/stderr를 읽는다. 좌표 문제면 `EventBus.tile_clicked`로 emit되는 셀 값과, 실제 클릭한 화면 위치를 비교한다.
3. Y-sort 문제면 `godot-run`으로 실제 창을 띄워 가림 순서를 눈으로 확정하고, 의심 노드의 `y_sort_enabled`/`z_index`/`position`을 해당 `.tscn`에서 직접 확인한다. (Coding-Solo/godot-mcp에는 스크린샷 도구가 없다 — 스크린샷을 제공하는 다른 서버를 쓴다면 그 도구로 캡처해도 된다.)

godot MCP 사용 상세는 `godot-mcp-workflow` 스킬을 참고한다.

## 2단계 — Y-sort 어긋남 체크리스트

깊이 정렬은 규약이 하나라도 깨지면 무너진다. 위에서 아래로 점검한다.

1. **`y_sort_enabled`**: 정렬을 기대하는 노드와 그 **부모 컨테이너**(예: `World`)의 CanvasItem `y_sort_enabled`가 `true`인가. Y-sort는 이 속성이 true일 때만 동작한다.
2. **같은 부모 아래 정렬**: 함께 정렬돼야 할 캐릭터·오브젝트·ObjectLayer가 **같은 Y-sort 부모** 아래에 있는가. 다른 부모에 흩어져 있으면 서로 정렬되지 않는다.
3. **z_index 그룹**: Godot은 **같은 `z_index`끼리만** Y-sort 비교한다. 두 가지를 함께 본다.
   - ① 바닥(GroundLayer, 비 Y-sort)은 정렬 그룹보다 **낮은** `z_index`(예: -1)인가 → 항상 뒤(배경)로 격리. 같은 z에 두면 레이어 전체가 한 덩어리로 정렬되어 깨진다.
   - ② **함께 정렬돼야 할 노드(ObjectLayer ↔ 캐릭터)가 같은 `z_index`(예: 0)를 공유**하는가 → 캐릭터 `z_index`를 ObjectLayer와 다르게 주면(또는 ObjectLayer만 z를 올리면) Y와 무관하게 한쪽이 항상 앞/뒤로 고정된다(매우 흔한 버그). 본 템플릿은 ObjectLayer=Player=0, GroundLayer=-1.
4. **Y Sort Origin**: 타일/스프라이트의 정렬 기준점이 발밑이 아니라 중심/머리에 있으면 순서가 뒤집힌다. TileMapLayer는 **Y Sort Origin(`y_sort_origin`, 픽셀)** 으로, 스프라이트는 오프셋으로 기준점을 발밑(아랫변)에 맞춘다.

해당 씬의 `.tscn`을 Read로 열어 위 속성들을 직접 확인하고, 어긋난 항목만 Edit으로 고친다.

## 3단계 — 좌표 변환 오류 체크리스트

1. **글로벌 → 로컬 누락**: 런타임 셀 변환은 `local_to_map`/`map_to_local`을 우선 쓴다. 전역 마우스 좌표를 그대로 `local_to_map`에 넣으면 어긋난다. 반드시 먼저 로컬화한다 — `tilemap.local_to_map(tilemap.to_local(get_global_mouse_position()))`.
2. **변환 함수 짝 확인**: 직접 계산할 때 `IsoUtils.cart_to_iso` ↔ `iso_to_cart`, `map_to_screen` ↔ `screen_to_map`이 서로 역함수가 되는지 라운드트립으로 확인한다(`test/unit/iso_utils_test.gd`의 라운드트립 테스트가 기준).
3. **tile_size 일관성**: 변환에 넘기는 `tile_size`가 실제 타일셋·TileMapLayer 설정과 같은 값인가. 표준 2:1 아이소는 폭=높이×2이며, 공식은 `screen.x = (cart.x - cart.y) * (tile_size.x/2)`, `screen.y = (cart.x + cart.y) * (tile_size.y/2)`.
4. **타일셋 모양**: TileSet의 Tile Shape가 **Isometric**으로 설정됐는지, Tile Layout/Offset Axis가 의도대로인지 확인한다(직교로 두면 셀 매핑이 전부 어긋난다).

좌표 산술이 의심되면 `godot-test` 스킬로 `test/unit/iso_utils_test.gd`를 돌려 라운드트립이 깨지는 성분을 특정한다.

## 4단계 — API 동작 확인 (context7)

`local_to_map`/`map_to_local`/`y_sort_origin`/`y_sort_enabled` 등의 시그니처·동작이 조금이라도 의심되면 **추정하지 말고** context7 MCP로 확인한다.

- `resolve-library-id` → `query-docs`, libraryId `/godotengine/godot-docs`.
- 확인한 사실을 가설 검증에 반영하고, 필요한 한 군데만 고친다.

## 5단계 — 수정·재검증

- 한 번에 한 가설씩 고치고, 매번 1단계로 돌아가 godot MCP 디버그 출력/스크린샷으로 증상이 사라졌는지 확인한다.
- 좌표 로직을 고쳤다면 `godot-test` 스킬로 회귀를 막는다. 새 경계 케이스가 드러나면 `superpowers:test-driven-development`로 실패 테스트를 먼저 추가한다.

## 주의

- 여러 항목을 동시에 바꾸지 않는다(원인 분리 불가). 한 번에 하나.
- 추측으로 우회하지 말고, API 사실은 공식 문서(context7)로 확정한 뒤 고친다.
