---
name: new-iso-scene
description: 새 아이소메트릭 씬을 스캐폴딩한다. $ARGUMENTS로 씬 이름을 받아 scenes/ 또는 src/entities/ 아래에 .tscn + .gd를 생성한다. godot-project-conventions 규약(TileMapLayer/Y-sort)을 준수한다. /new-iso-scene 으로 호출.
argument-hint: "[씬 이름] (예: enemy, level_2)"
allowed-tools: Read, Write, Edit, Glob, Grep
---

# /new-iso-scene — 아이소 씬 스캐폴딩

`$ARGUMENTS`로 받은 이름의 새 아이소메트릭 씬과 스크립트를 생성한다. 이름이 없으면 사용자에게 씬 이름과 종류(월드 씬 / 엔티티)를 먼저 물어본다.

## 0단계 — 규약 확인 (먼저)

작업 전 `godot-project-conventions` 스킬을 읽어 이 템플릿의 디렉터리·네이밍·시그널 규약을 확정한다. 핵심:

- 파일·디렉터리 이름은 **snake_case**, `class_name`은 **PascalCase**.
- 정적 타이핑 적극 사용, 들여쓰기는 **탭**, private 멤버는 `_` 프리픽스, 주석은 한국어.
- 전역 통신은 `EventBus`(autoload) 시그널을 통한 느슨한 결합.

## 1단계 — 배치 위치 결정

이름과 종류에 따라 둘 중 하나에 둔다(디렉터리 트리 준수).

- **월드/레벨/UI 씬** → `scenes/<name>.tscn` + `scenes/<name>.gd`
- **엔티티(플레이어/적/오브젝트 등)** → `src/entities/<name>/<name>.tscn` + `src/entities/<name>/<name>.gd`

기존 같은 이름 파일이 있으면 덮어쓰지 말고 사용자에게 확인한다.

## 2단계 — 스크립트(.gd) 생성

엔티티인지 월드 씬인지에 맞춰 작성한다.

- **월드 씬**: `extends Node2D`. 첫 줄 다음에 한국어 `##` 문서 주석. 필요한 자식은 `@onready var world: Node2D = $World` 처럼 씬 구조와 정확히 일치시킨다.
- **엔티티(움직이는 캐릭터)**: `class_name <Pascal>` + `extends CharacterBody2D`. `@export var speed: float = 180.0`, `@onready var _sprite: Sprite2D = $Sprite2D`. `_physics_process`에서 `Input.get_vector(...)` → `velocity` → `move_and_slide()`. `_ready`에서 필요한 `EventBus` 시그널을 emit.

좌표 변환이 필요하면 직접 계산하지 말고 다음을 따른다.

- 런타임에 마우스/노드 위치를 셀로 바꿀 때는 **TileMapLayer.local_to_map / map_to_local 우선**: `var cell := tilemap.local_to_map(tilemap.to_local(get_global_mouse_position()))`.
- 논리 그리드 ↔ 스크린 픽셀 변환은 `IsoUtils`의 static 메서드(`cart_to_iso`, `iso_to_cart`, `map_to_screen`, `screen_to_map`, `depth`)를 사용한다.

## 3단계 — 씬(.tscn) 생성

Godot 4 텍스트 씬 포맷 `format=3`. `ext_resource`는 `type`+`path`+`id`로 참조한다(손으로 작성할 땐 `uid` 생략 가능 — path로 로드됨). `load_steps`는 `ext_resource 수 + sub_resource 수 + 1`로 맞춰 둔다(Godot 4.6+ 에디터는 `load_steps`를 기록하지 않지만 남아 있어도 무해).

- **월드 씬 노드 트리(Y-sort 구성 필수)** — `scenes/main.tscn`과 같은 골격을 따른다:

  ```
  [node name="<Name>" type="Node2D"]            # script = <name>.gd
    [node name="World" type="Node2D" parent="."] # y_sort_enabled = true
      [node name="GroundLayer" type="TileMapLayer" parent="World"]  # y_sort_enabled=false, z_index=-1
      [node name="ObjectLayer" type="TileMapLayer" parent="World"]  # y_sort_enabled=true,  z_index=0
  ```

  - 깊이 정렬은 **CanvasItem의 `y_sort_enabled = true`** 일 때만 동작한다. 움직이는 노드(캐릭터)와 ObjectLayer는 같은 Y-sort 부모(`World`) 아래 둔다.
  - **z_index 규칙**: 바닥(GroundLayer, 비 Y-sort)은 더 낮은 `z_index=-1`로 정렬 그룹 뒤에 두고, 함께 정렬할 ObjectLayer(`z_index=0`)와 움직이는 캐릭터(z_index 기본 0)는 **같은 `z_index`(=0)** 를 공유한다. Godot은 같은 z_index끼리만 Y-sort 비교하므로, 캐릭터의 z_index를 ObjectLayer와 다르게 주면 앞/뒤 정렬이 동작하지 않는다.
  - 타일별 정렬 기준점이 필요하면 ObjectLayer에 **Y Sort Origin(`y_sort_origin`, 픽셀)** 을 준다.
  - TileMapLayer는 `tile_set` 없이 비워둔다. 아이소 타일셋은 에디터에서 Tile Shape를 **Isometric**으로 만든 뒤 연결한다(상세는 `godot-isometric` 스킬·`docs/ARCHITECTURE.md` 참고).

- **엔티티 씬 노드 트리** — `src/entities/player/player.tscn`을 따른다:

  ```
  [node name="<Name>" type="CharacterBody2D"]   # script = <name>.gd
    [node name="Sprite2D" type="Sprite2D" parent="."]            # texture = res://icon.svg 등
    [node name="CollisionShape2D" type="CollisionShape2D" parent="."]  # SubResource CircleShape2D
  ```

  - 충돌 형태는 `[sub_resource type="CircleShape2D" id="..."]`로 만들고 `load_steps`에 그 수를 포함한다(sub_resource도 step 1개로 계산).

## 4단계 — 검증

- 노드 이름이 스크립트의 `@onready`/`$` 경로와 정확히 일치하는지 확인한다(불일치는 런타임 null 에러의 흔한 원인).
- `godot-run` 스킬(`/godot-run res://<생성한 씬 경로>`)로 실행해 파스 에러·경로 누락이 없는지 본다.
- 좌표/Y-sort가 의심되면 `iso-debug` 스킬 절차로 넘어간다.

## 주의

- 기존 정본 파일(`scenes/main.tscn`, `src/entities/player/*` 등)은 건드리지 않는다. 새 씬만 추가한다.
- API가 조금이라도 불확실하면 추정하지 말고 context7 MCP(`/godotengine/godot-docs`)로 확인한다.
