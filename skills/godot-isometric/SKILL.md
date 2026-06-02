---
name: godot-isometric
description: 아이소메트릭 좌표/Y-sort/TileMapLayer를 다룰 때 사용
---

# godot-isometric — 아이소메트릭 2D 핵심 지식

Godot 4(4.4+) 아이소메트릭 2D에서 좌표 변환, Y-sort(깊이 정렬), `TileMapLayer`를
다룰 때 참조하는 스킬이다. 본 템플릿의 `IsoUtils`(`src/systems/iso_utils.gd`)와
씬 구성 규약에 맞춰 작성되었다.

이 스킬을 쓰는 상황:

- 셀(논리 그리드) 좌표와 화면 픽셀 좌표를 서로 변환해야 할 때
- 마우스 클릭 위치로 타일 셀을 알아내야 할 때
- 캐릭터·오브젝트가 타일 뒤/앞 순서로 그려지지 않을 때(Y-sort)
- `TileMapLayer` 노드를 새로 구성하거나 정렬 기준을 조정할 때

---

## 1. 아이소 좌표계 개념

### 직교 그리드 ↔ 아이소 스크린

게임 로직은 **직교(Cartesian) 그리드** — 정사각형 격자 위의 `(x, y)` 정수 좌표 —
로 다루는 편이 단순하다. 화면에는 이 격자를 **2:1 다이아몬드**(타일 폭이 높이의
2배인 마름모)로 비스듬히 투영해 그린다. 그래서 로직 좌표와 화면 픽셀 좌표는
서로 다르며, 둘 사이를 변환하는 수식이 필요하다.

- **직교 그리드(cart)**: 게임 규칙·이동·경로 탐색이 사는 곳. `(0,0)`에서
  오른쪽으로 x, 아래로 y가 증가.
- **아이소 스크린(iso)**: 실제 픽셀로 그려지는 곳. 같은 격자 한 칸이
  마름모 한 칸이 된다.

표준 2:1 아이소에서는 `tile_size = Vector2(타일 폭, 타일 높이)`이고
보통 `타일 폭 = 타일 높이 * 2`(예: `Vector2(64, 32)`)이다. 본 템플릿의
`IsoUtils`는 폭=높이*2를 기본 가정하되 `tile_size` 인자로 일반화한다.

### 변환 수식(표준 아이소)

직교 → 아이소 스크린:

```
screen.x = (cart.x - cart.y) * (tile_size.x / 2)
screen.y = (cart.x + cart.y) * (tile_size.y / 2)
```

- `cart.x`가 늘면 화면에서 오른쪽-아래로, `cart.y`가 늘면 왼쪽-아래로 간다.
- 두 좌표의 **합**(`cart.x + cart.y`)이 클수록 화면 아래쪽 = 더 가까운(앞) 칸.

역변환(아이소 스크린 → 직교)은 위 식을 풀면 다음과 같다:

```
cart.x = (screen.x / (tile_size.x / 2) + screen.y / (tile_size.y / 2)) / 2
cart.y = (screen.y / (tile_size.y / 2) - screen.x / (tile_size.x / 2)) / 2
```

> 주의: 이 수식은 직교↔아이소 **좌표 모델**을 직접 계산할 때 쓴다.
> 실제 씬에 `TileMapLayer`가 있다면 아래 2절의 `local_to_map`/`map_to_local`을
> 우선 사용하라. 그 메서드들은 TileSet에 설정된 타일 모양·오프셋을 반영하므로
> 수식을 손으로 맞추는 것보다 정확하고 안전하다.

---

## 2. TileMapLayer 좌표 변환

`TileMapLayer`는 셀↔로컬 픽셀 변환 메서드를 제공한다(Godot 4 검증).

- `local_to_map(local_position: Vector2) -> Vector2i`
  로컬 픽셀 위치를 포함하는 셀 좌표를 반환한다.
- `map_to_local(map_position: Vector2i) -> Vector2`
  셀 좌표를 로컬 픽셀 위치(**셀 중심**)로 변환한다.

이 두 메서드는 TileSet의 Tile Shape(Isometric 포함)·레이아웃 설정을 그대로
반영하므로, 아이소 타일맵에서도 추가 보정 없이 동작한다.

### 전역 좌표는 to_local()으로 선처리

`local_to_map`은 **로컬** 좌표를 받는다. 마우스 위치나 다른 노드의 전역 좌표를
다룰 땐 반드시 `Node2D.to_local(global_pos)`로 먼저 로컬화한 뒤 넘긴다.

```gdscript
# 마우스가 가리키는 타일 셀 구하기
var global_pos := get_global_mouse_position()
var cell := tilemap.local_to_map(tilemap.to_local(global_pos))
EventBus.tile_clicked.emit(cell)
```

반대로 셀의 화면 위치(전역)가 필요하면 `to_global()`로 되돌린다:

```gdscript
var local_center := tilemap.map_to_local(cell)
var global_center := tilemap.to_global(local_center)
```

> `TileMap` 단일 노드는 Godot 4.3부터 deprecated다. 본 템플릿은 개별
> `TileMapLayer` 노드를 사용한다(레이어별로 노드를 분리).

---

## 3. Y-sort (깊이 정렬)

아이소에서는 화면 아래쪽 = 더 앞이다. 노드를 Y 좌표 순으로 그려야 캐릭터가
타일·오브젝트의 앞/뒤로 자연스럽게 가려진다. Godot의 Y-sort가 이를 처리한다.

### 핵심 규칙

- **`CanvasItem.y_sort_enabled = true`** 일 때만 Y-sort가 동작한다.
  부모 노드에 켜면, 그 자식 `CanvasItem`들이 Y 위치 순으로 정렬돼
  Y가 큰(아래쪽) 노드가 앞에 그려진다.
- **부모에 켜고 자식에 끄는** 구조가 가능하다. 부모('A')에 Y-sort가 켜져 있고
  자식('B')에 꺼져 있으면, B 자신은 정렬되지만 B의 자식들(C1, C2…)은 B와 같은
  Y 위치에서 한 덩어리로 그려진다. 씬 트리를 바꾸지 않고 렌더 순서를 묶을 때 쓴다.
- **같은 `z_index`일 때만 서로 정렬**된다. 노드들은 같은 z_index 안에서만 Y로
  비교된다. 그래서 **Y-sort 레이어와 비-Y-sort 레이어는 서로 다른 `z_index`**를
  둔다. 안 그러면 바닥 레이어와 오브젝트 레이어가 한 덩어리로 섞여 정렬돼
  의도치 않게 가려진다.

### TileMapLayer의 y_sort_origin

`TileMapLayer`는 렌더링 속성 **Y Sort Origin**(`y_sort_origin`, 픽셀 단위)으로
타일별 정렬 기준점을 위/아래로 오프셋한다. 키 큰 오브젝트(벽·나무)는 밑동이
정렬 기준이 되도록 origin을 내려야 캐릭터와 올바르게 가려진다.

- `y_sort_origin`은 **Y Sort Enabled(`y_sort_enabled`)가 true일 때만** 적용된다.
- 타일 하나하나에 대해서는 TileSet의 타일 데이터에 `y_sort_origin`(TileData)을
  지정할 수도 있다. 레이어 전체 기준을 옮길 땐 노드의 `y_sort_origin`을 쓴다.
- 참고: Y-sort된 `TileMapLayer`는 타일이 Y 위치로 그룹화되므로
  Rendering Quadrant Size 최적화가 적용되지 않는다.

### 캐릭터 정렬

플레이어 같은 움직이는 노드도 **타일과 같은 Y-sort 컨테이너(부모) 아래** 두고
부모의 `y_sort_enabled = true`로 함께 정렬한다. 캐릭터와 오브젝트 레이어가
같은 `z_index`를 공유해야 서로 비교되어 앞/뒤가 맞는다.

본 템플릿 `scenes/main.tscn`의 구조가 이 원칙을 반영한다:

```
Main (Node2D)
└─ World (Node2D)            # y_sort_enabled = true  ← 컨테이너
   ├─ GroundLayer (TileMapLayer)   # 바닥, y_sort_enabled = false, z_index = -1
   ├─ ObjectLayer (TileMapLayer)   # 오브젝트, y_sort_enabled = true, z_index = 0
   └─ Player (CharacterBody2D)     # z_index 기본 0 → ObjectLayer와 같은 그룹에서 정렬
```

- `GroundLayer`(바닥)는 항상 맨 아래 → Y-sort 끄고 `z_index = -1`(정렬 그룹보다 뒤).
- `ObjectLayer`(z_index=0)와 `Player`(z_index 기본 0)는 **같은 z_index(0)** 라서 Y로 정렬되어 앞/뒤가 맞는다. (Godot은 같은 z_index끼리만 Y-sort 비교한다.)
- 컨테이너 `World`에 Y-sort를 켜 자식 전체의 정렬을 주관한다.

---

## 4. IsoUtils 헬퍼 사용 예시

본 템플릿은 좌표 모델 계산용 정적 헬퍼 `IsoUtils`(`res://src/systems/iso_utils.gd`)를
제공한다. 모든 메서드가 `static`이며 `RefCounted`를 확장한다. 시그니처는 고정이다.

- `IsoUtils.cart_to_iso(cart: Vector2, tile_size: Vector2) -> Vector2`
  직교(논리 그리드) → 아이소 스크린 픽셀.
- `IsoUtils.iso_to_cart(iso: Vector2, tile_size: Vector2) -> Vector2`
  아이소 스크린 픽셀 → 직교.
- `IsoUtils.map_to_screen(cell: Vector2i, tile_size: Vector2) -> Vector2`
  셀 좌표 → 스크린 픽셀(타일 중심).
- `IsoUtils.screen_to_map(screen: Vector2, tile_size: Vector2) -> Vector2i`
  스크린 픽셀 → 셀 좌표(반올림).
- `IsoUtils.depth(cell: Vector2i) -> int`
  Y-sort 보조용 깊이값(`cell.x + cell.y`). 값이 클수록 앞(아래) 칸.

```gdscript
const TILE := Vector2(64, 32)  # 2:1 아이소 타일

# 논리 격자 (3,1) 칸의 화면 픽셀 위치
var screen_pos := IsoUtils.map_to_screen(Vector2i(3, 1), TILE)

# 화면 픽셀을 다시 격자 셀로
var cell := IsoUtils.screen_to_map(screen_pos, TILE)  # → Vector2i(3, 1)

# 두 칸의 그리기 순서 비교 (깊이값이 큰 쪽이 앞)
if IsoUtils.depth(cell_a) > IsoUtils.depth(cell_b):
    pass  # cell_a가 cell_b보다 앞(아래)
```

> 중요: **런타임에 실제 씬의 셀을 변환할 때는 `TileMapLayer.local_to_map`/
> `map_to_local`을 우선 사용하라.** `IsoUtils`는 TileMapLayer가 없는 순수
> 좌표 계산, 테스트, 또는 입력 벡터를 아이소 축에 맞추는 보정용이다.

---

## 5. 흔한 함정 체크리스트

타일/캐릭터 정렬이나 클릭 좌표가 어긋날 때 아래를 순서대로 점검한다.

- [ ] **클릭 좌표가 한 칸씩/대각으로 어긋남** — `local_to_map`에 전역 좌표를
      그대로 넘기지 않았는지. `tilemap.to_local(global_pos)`로 선처리해야 한다.
- [ ] **셀 위치 계산이 카메라/줌과 안 맞음** — 카메라 변환이 끼는 경우
      `get_global_mouse_position()`을 쓰고 다시 `to_local`로 변환했는지.
- [ ] **캐릭터가 항상 타일 앞/뒤에만 그려짐** — 컨테이너(부모)에
      `y_sort_enabled`가 켜져 있는지, 캐릭터와 오브젝트 레이어가 **같은
      `z_index`**인지(다르면 서로 비교되지 않음).
- [ ] **바닥과 오브젝트가 한 덩어리로 섞여 정렬됨** — 바닥(비 Y-sort)과
      오브젝트(Y-sort) 레이어의 `z_index`를 분리했는지.
- [ ] **키 큰 오브젝트의 발밑이 어긋남** — 해당 레이어/타일의
      `y_sort_origin`을 밑동 기준으로 내렸는지(`y_sort_enabled=true` 전제).
- [ ] **타일이 안 그려짐** — `TileMapLayer`에 TileSet이 할당됐는지, Tile Shape가
      **Isometric**으로 설정됐는지(본 템플릿 씬은 TileSet을 비워 두고 문서에서
      추가를 안내한다).
- [ ] **IsoUtils 결과가 어긋남** — `tile_size`가 실제 타일과 일치하는지
      (폭=높이*2 가정 확인), 화면 변환에 `to_global`/`to_local`을 빠뜨리지 않았는지.

---

## 6. 디버깅 안내

좌표·Y-sort 문제는 추측보다 단계적 검증이 빠르다.

- **`/iso-debug`** — 본 템플릿의 아이소 전용 디버깅 절차 커맨드. Y-sort 설정·
  z_index·좌표 변환을 순서대로 점검한다. 먼저 실행해 본다.
- **`superpowers:systematic-debugging`** — 문제가 단순 점검으로 안 풀리면
  체계적 디버깅 스킬로 가설을 세우고 좁혀 나간다.
- **context7 MCP** — Godot 4 API(메서드 시그니처·속성)가 불확실하면
  libraryId `/godotengine/godot-docs`로 최신 문서를 확인한다.
