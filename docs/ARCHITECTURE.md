# 아키텍처 (ARCHITECTURE)

이 문서는 본 아이소메트릭 2D 템플릿의 **폴더 구조**, **런타임 노드 트리**, **데이터 흐름(시그널)**,
그리고 **확장 방법**을 설명한다. 코드 자체의 설치/실행 방법은 `docs/SETUP.md`를, 파일별 정본 시그니처는
`AGENTS.md`의 핵심 규약과 각 `.gd`/`.tscn` 코드를 참조한다. 이 문서는 "어디에 무엇이 있고, 어떻게 연결되는가"에 집중한다.

용어: `res://`는 프로젝트 루트(이 워크트리 루트)를 가리킨다.

---

## 1. 디렉토리 구조와 역할

```
godot-template/
├── AGENTS.md                              # 도구 무관 정본 지침(Codex 등이 직접 읽음)
├── skills/                                # 공용 스킬(SKILL.md) — Claude·Codex 공유
│   ├── godot-isometric/SKILL.md           # 아이소 좌표·Y-sort·TileMapLayer 핵심 지식
│   ├── godot-mcp-workflow/SKILL.md        # Godot MCP로 에디터 제어
│   ├── gdunit4-testing/SKILL.md           # GdUnit4 설치·테스트 패턴·TDD 루프
│   ├── godot-project-conventions/SKILL.md # 본 템플릿의 구조/네이밍 규약
│   ├── godot-run/SKILL.md                 # /godot-run     씬/프로젝트 실행(워크플로 스킬)
│   ├── godot-test/SKILL.md                # /godot-test    GdUnit4 테스트 실행
│   ├── new-iso-scene/SKILL.md             # /new-iso-scene 아이소 씬 스캐폴딩
│   └── iso-debug/SKILL.md                 # /iso-debug     Y-sort·좌표 디버깅 절차
├── .claude/                               # Claude Code 전용 연동 (글로벌 설정 불필요)
│   ├── CLAUDE.md                          # @../AGENTS.md import + Claude 전용 설정
│   ├── settings.json                      # 플러그인/마켓플레이스/권한/MCP 활성화
│   ├── agents/godot-specialist.md         # Godot 전문 서브에이전트(Claude 전용 메커니즘)
│   └── skills → ../skills                 # 심볼릭 링크(Claude 스킬 경로)
├── .codex/                                # Codex CLI 설정
│   ├── config.toml                        # MCP 서버 정의(.mcp.json과 동등)
│   └── skills → ../skills                 # 심볼릭 링크(Codex 스킬 경로)
├── .agents/                               # 에이전트 공용
│   └── skills → ../skills                 # 심볼릭 링크(도구·버전별 탐지 경로 커버)
├── .mcp.json                              # context7 + godot MCP 서버 정의(Claude용)
├── .github/pull_request_template.md       # AI 작업용 PR 템플릿
├── .gitignore / .gitattributes            # Godot용 VCS 설정
├── project.godot                          # 프로젝트 설정: autoload·input·rendering
├── icon.svg                               # 아이소 다이아몬드 아이콘
├── README.md                              # 템플릿 사용 안내(한국어)
├── docs/
│   ├── SETUP.md                           # 설치: Godot·MCP·플러그인·GdUnit4·Codex·선택 스킬
│   ├── ARCHITECTURE.md                    # (이 문서) 구조·데이터 흐름·시그널 규약
│   ├── GODOT_CONVENTIONS.md               # Godot 공식 컨벤션(context7 검증)
│   └── COMMIT_CONVENTIONS.md              # 커밋 메시지 규칙
├── src/                                   # 게임 로직 소스(씬과 분리)
│   ├── autoload/                          # 싱글톤(autoload)
│   │   ├── event_bus.gd                   # autoload "EventBus" — 전역 시그널 허브
│   │   └── game_state.gd                  # autoload "GameState" — 전역 상태 싱글톤
│   ├── systems/                           # 재사용 가능한 시스템/헬퍼
│   │   ├── iso_utils.gd                   # class_name IsoUtils — 좌표 변환 정적 헬퍼
│   │   └── state_machine.gd               # class_name StateMachine — 노드 기반 FSM
│   └── entities/                          # 게임 엔티티(노드+스크립트+씬 묶음)
│       └── player/
│           ├── player.gd                  # class_name Player extends CharacterBody2D
│           └── player.tscn                # Player 씬
├── scenes/                                # 실행 가능한 씬(화면 단위)
│   ├── main.tscn                          # 메인 씬 (run/main_scene)
│   └── main.gd                            # 메인 씬 컨트롤러 스크립트
├── assets/                                # 텍스처·타일셋·사운드 등 (.gitkeep로 빈 폴더 유지)
└── test/
    └── unit/
        └── iso_utils_test.gd              # GdUnit4 예제 테스트 (IsoUtils 검증)
```

### 폴더 설계 원칙

- **`src/` vs `scenes/` 분리**: `src/`는 재사용/엔진 독립적인 로직(시스템·엔티티 정의)을,
  `scenes/`는 "화면" 단위로 조립된 실행 씬을 담는다. 엔티티(`src/entities/player/`)는
  스크립트와 씬을 한 폴더에 묶어 응집도를 높인다.
- **`autoload`는 전역 단일 인스턴스**: 어디서나 이름(`EventBus`, `GameState`)으로 접근한다.
- **`systems`는 상태를 거의 갖지 않는 도구**: `IsoUtils`는 순수 정적 함수, `StateMachine`은
  씬에 인스턴스로 붙여 쓰는 노드.
- **`assets/`는 빈 채로 시작**: 타일셋·스프라이트는 사용자가 추가한다. 템플릿은 의존 에셋 없이 실행된다.

---

## 2. 런타임 노드 트리 (main.tscn)

게임을 실행하면 `scenes/main.tscn`이 루트로 로드된다. 트리는 다음과 같이 고정되어 있다.

```
Main (Node2D)                         ← scenes/main.gd 부착
├── World (Node2D)                    ← y_sort_enabled = true  (깊이 정렬 컨테이너)
│   ├── GroundLayer (TileMapLayer)    ← 바닥. y_sort_enabled = false, z_index = -1
│   ├── ObjectLayer (TileMapLayer)    ← 오브젝트/장애물. y_sort_enabled = true, z_index = 0
│   └── Player (player.tscn 인스턴스) ← CharacterBody2D (z_index 기본 0 → ObjectLayer와 같은 그룹)
│       └── Camera2D                  ← Player의 자식 → 플레이어를 따라감
└── CanvasLayer
    └── Hint (Label)                  ← 조작 안내 UI (월드 좌표와 무관, 화면 고정)
```

### 각 노드의 역할

- **Main (Node2D)** — 최상위 컨트롤러. `main.gd`가 부착되어 입력 처리와 데모 동작을 담당한다.
  `@onready var world: Node2D = $World`로 하위를 참조한다.
- **World (Node2D)** — **Y-sort의 핵심 컨테이너**. `y_sort_enabled = true`이므로 이 노드의
  직계 자식들이 화면 Y좌표 기준으로 그려지는 순서가 정해진다. 플레이어와 오브젝트 레이어를
  같은 부모 아래 두는 이유가 바로 이것이다(3절·6절 참조).
- **GroundLayer (TileMapLayer)** — 바닥 타일. 깊이 정렬이 필요 없으므로 `y_sort_enabled = false`,
  `z_index = -1`로 정렬 그룹보다 뒤(배경)에 항상 깔린다.
- **ObjectLayer (TileMapLayer)** — 벽·나무 등 플레이어와 앞뒤가 바뀔 수 있는 오브젝트.
  `y_sort_enabled = true`, `z_index = 0`으로 두어 **같은 z_index(=0)** 인 플레이어와 함께 Y-sort된다.
- **Player (인스턴스)** — `src/entities/player/player.tscn`을 인스턴스한 것. `CharacterBody2D`로
  이동하며, `z_index` 기본값(0)이라 ObjectLayer와 같은 그룹에서 Y-sort에 참여해 오브젝트 타일과 자연스럽게 가려지거나 가린다.
- **Camera2D** — `World/Player`의 자식이라 플레이어를 따라간다(별도 추적 스크립트 없이 부모-자식 관계만으로).
- **CanvasLayer → Hint (Label)** — `CanvasLayer`는 월드 변환·카메라 이동의 영향을 받지 않는
  별도 렌더 레이어다. UI는 항상 화면에 고정되어야 하므로 여기에 둔다. `Hint`의 텍스트는
  "WASD/화살표 이동, 좌클릭으로 타일 좌표 출력" 같은 조작 안내를 표시한다.

> 참고: TileMapLayer에는 처음에 `tile_set`이 비어 있다. 타일셋을 붙이는 방법은 `SETUP.md`와
> `godot-isometric` 스킬에서 안내한다(에디터에서 TileSet의 Tile Shape를 Isometric으로 설정).

---

## 3. Y-sort 렌더링 파이프라인

아이소메트릭 2D에서 "누가 누구 앞에 그려지는가"는 게임의 핵심이다. 본 템플릿은 Godot의 Y-sort
기능으로 이를 처리한다. 정리하면 세 가지 속성이 함께 작동한다.

### (1) `y_sort_enabled` — 정렬을 켜는 스위치

`CanvasItem`(Node2D·TileMapLayer 등)의 속성. `true`일 때만 깊이 정렬이 동작한다.
**정렬은 같은 부모의 자식들 사이에서, 화면 Y좌표가 작은(위쪽) 것부터 그려지는 방식**이다.
즉 화면상 아래에 있는 객체가 더 늦게(앞에) 그려진다 — 이것이 "가까운 것이 앞" 효과를 만든다.

본 템플릿에서:
- `World.y_sort_enabled = true` → World의 직계 자식(GroundLayer·ObjectLayer·Player)이 정렬 대상.
- `ObjectLayer.y_sort_enabled = true` → ObjectLayer **내부의 타일들**도 서로 Y-sort.
- `GroundLayer.y_sort_enabled = false` → 바닥은 정렬할 필요가 없어 끔(성능·예측 가능성).

### (2) `z_index` — 정렬 "그룹"을 가르는 칸막이

`z_index`가 다르면 Y-sort 비교 자체를 하지 않고 z가 작은 것부터 통째로 먼저 그린다.
**Y-sort 레이어와 비-Y-sort 레이어는 서로 다른 `z_index`를 주는 것이 정석**이다.
같은 z에 섞으면 레이어 전체가 한 덩어리로 정렬되어 의도치 않게 바닥이 캐릭터 위로 올라오는 등의
문제가 생긴다.

본 템플릿:
- `GroundLayer.z_index = -1` → 정렬 그룹보다 뒤. 항상 맨 뒤(배경).
- `ObjectLayer.z_index = 0` + `Player`(World 자식, `z_index` 기본 0) → **같은 z_index(=0)** 라서 같은 깊이 그룹에서 Y좌표로 함께 정렬된다(핵심: 함께 정렬할 노드는 z_index를 같게 둔다).

### (3) `y_sort_origin` — 타일의 "발밑" 기준점

TileMapLayer는 타일 이미지가 셀 중심보다 위로 솟아 있는 경우(예: 키 큰 나무)가 많다. 이때
정렬 기준을 타일 이미지 꼭대기가 아니라 **타일이 땅에 닿는 지점(발밑)**으로 잡아야 한다.
이 오프셋이 `y_sort_origin`(픽셀)이다. TileSet 편집기에서 타일/레이어별로 지정한다.
캐릭터의 경우 스프라이트의 발 위치가 노드 원점이 되도록 배치(또는 오프셋)해 같은 기준을 맞춘다.

### 파이프라인 한눈에

```
        z_index 작은 그룹부터 → 같은 z 안에서 y_sort_enabled면 화면 Y로 정렬 → y_sort_origin으로 기준점 보정

GroundLayer(z=-1, no y-sort)  ────────────────────►  항상 배경
                                                          │
ObjectLayer(z=0, y-sort) ┐                                │
Player      (z=0 기본,    ├─ 같은 깊이 그룹에서          ▼
             World 자식) ┘   화면 Y가 작을수록 먼저(뒤),  최종 화면
                              클수록 나중(앞)에 그려짐
```

> API 확인(context7 `/godotengine/godot-docs`): `y_sort_enabled`가 정렬 스위치, `z_index`가
> 렌더 순서 그룹, `y_sort_origin`이 타일/노드별 정렬 기준점 오프셋이라는 역할 구분을 확인했다.

---

## 4. autoload 흐름 — EventBus와 GameState

두 싱글톤은 `project.godot`의 autoload에 등록되어 게임 시작 시 트리 최상단에 자동 생성된다.
어디서든 전역 이름으로 접근한다.

### EventBus — 전역 시그널 허브

`src/autoload/event_bus.gd` (`extends Node`, `class_name` 없음, autoload 이름은 `EventBus`).
노드들이 서로를 직접 참조하지 않고 **느슨하게 결합**되도록 시그널만 모아 둔 중계소다.
발행자(emit)는 누가 듣는지 모르고, 구독자(connect)는 누가 보내는지 몰라도 된다.

선언된 예시 시그널:

| 시그널 | 의미 | 인자 |
|--------|------|------|
| `player_spawned(player: Node)` | 플레이어 생성/등장 | 생성된 노드 |
| `player_died` | 플레이어 사망 | 없음 |
| `tile_clicked(cell: Vector2i)` | 타일 셀 클릭 | 셀 좌표 |
| `game_paused(paused: bool)` | 일시정지 상태 변경 | 현재 일시정지 여부 |

**발행(emit) 예 — Player가 등장을 알림 (`player.gd`의 `_ready`):**

```gdscript
func _ready() -> void:
	EventBus.player_spawned.emit(self)
```

**구독(connect) 예 — 다른 노드에서 클릭 좌표를 받으려면 (예시; 본 템플릿 `main.gd`는 클릭을 `_unhandled_input`에서 직접 처리·출력하고 `tile_clicked`를 emit만 한다):**

```gdscript
func _ready() -> void:
	EventBus.tile_clicked.connect(_on_tile_clicked)

func _on_tile_clicked(cell: Vector2i) -> void:
	print("clicked cell: ", cell)
```

### GameState — 전역 상태 싱글톤

`src/autoload/game_state.gd` (`extends Node`, autoload 이름 `GameState`).
점수·일시정지 같은 게임 전역 상태를 보관하고, 상태 변경 시 EventBus로 알린다.
**"상태는 GameState가 들고, 변경 통지는 EventBus가 한다"**가 둘의 역할 분담이다.

```gdscript
var score: int = 0
var is_paused: bool = false

func set_paused(p: bool) -> void:
	is_paused = p
	get_tree().paused = p           # 엔진 차원 일시정지
	EventBus.game_paused.emit(p)    # 관심 있는 노드에 통지

func add_score(n: int) -> void:
	score += n
```

### 데이터 흐름 다이어그램

```
   [Player]            [Main / 입력]              [UI·기타 노드]
      │ emit               │ emit                      ▲ connect
      │ player_spawned     │ tile_clicked              │ game_paused
      ▼                    ▼                           │
   ┌──────────────────────────────────────────────────────────┐
   │                        EventBus                            │  ← 시그널 허브(중계만)
   └──────────────────────────────────────────────────────────┘
                           ▲ emit(game_paused)
                           │
                      [GameState]  ← 상태 보관(score, is_paused) + 상태 변경 시 통지
```

핵심: 노드 간 직접 호출 대신 EventBus를 거치므로, 새 구독자를 추가해도 발행자 코드는 바뀌지 않는다.

---

## 5. 좌표 변환 — IsoUtils vs TileMapLayer

아이소 좌표 변환은 **두 가지 도구**가 명확히 다른 역할을 맡는다. 혼동하면 좌표가 어긋난다.

### IsoUtils — 정적 헬퍼 (논리 ↔ 스크린 수학)

`src/systems/iso_utils.gd` (`class_name IsoUtils extends RefCounted`). 인스턴스 없이
`IsoUtils.cart_to_iso(...)`처럼 호출하는 순수 정적 함수 모음이다. **TileMapLayer 노드가 없거나,
타일셋과 무관한 자체 그리드 계산이 필요할 때** 쓴다.

| 메서드 | 용도 |
|--------|------|
| `cart_to_iso(cart, tile_size) -> Vector2` | 직교(논리 그리드) → 아이소 스크린 픽셀 |
| `iso_to_cart(iso, tile_size) -> Vector2` | 아이소 스크린 픽셀 → 직교 |
| `map_to_screen(cell, tile_size) -> Vector2` | 셀 좌표 → 스크린 픽셀(타일 중심) |
| `screen_to_map(screen, tile_size) -> Vector2i` | 스크린 픽셀 → 셀 좌표(반올림) |
| `depth(cell) -> int` | Y-sort 보조 깊이값(`cell.x + cell.y`) |

표준 2:1 아이소 변환식:
`screen.x = (cart.x - cart.y) * (tile_size.x / 2)`,
`screen.y = (cart.x + cart.y) * (tile_size.y / 2)`.

### TileMapLayer.local_to_map / map_to_local — 런타임 셀 변환 (권장)

**실제 씬에 TileMapLayer가 있다면 이쪽이 우선이다.** 엔진이 타일셋의 모양·오프셋·아이소 설정을
모두 반영해 변환하므로, 타일셋 설정과 항상 일치한다.

- `local_to_map(local_position: Vector2) -> Vector2i` — 로컬 픽셀 위치를 포함하는 셀 좌표.
- `map_to_local(map_position: Vector2i) -> Vector2` — 셀 좌표 → 로컬 픽셀(셀 중심).

전역 좌표(예: 마우스)는 먼저 `Node2D.to_local(global_pos)`로 로컬화한 뒤 `local_to_map`에 넣는다.
`main.gd`의 클릭 데모가 이 패턴을 쓴다(실제 코드는 가독성을 위해 두 줄로 나눔):

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos := object_layer.to_local(get_global_mouse_position())
		var cell := object_layer.local_to_map(local_pos)
		EventBus.tile_clicked.emit(cell)
```

### 역할 구분 요약

- **IsoUtils** = "타일셋과 독립적인 순수 수학". 테스트·미리보기·커스텀 그리드용.
- **TileMapLayer 메서드** = "실제 타일셋이 적용된 런타임 셀 변환". 게임 플레이 좌표는 이쪽 우선.

> `IsoUtils` 주석에도 "런타임 셀 변환은 `TileMapLayer.local_to_map` / `map_to_local`을 우선 사용하라"고
> 명시되어 있다.

---

## 6. StateMachine — 노드 기반 FSM 사용법

`src/systems/state_machine.gd` (`class_name StateMachine extends Node`). **자식 노드 하나가 곧 하나의
상태**인 간단한 유한 상태 기계다. 별도의 State 베이스 클래스를 강제하지 않고, 메서드 존재 여부로
판단하는 **덕 타이핑** 방식이라 가볍다.

### 구성

```
StateMachine            ← initial_state(NodePath) 지정, 자식으로 위임
├── Idle  (Node)        ← _enter(msg)/_exit()/_update(delta)/_physics_update(delta) 중 필요한 것만 구현
├── Walk  (Node)
└── Attack (Node)
```

- 상태 노드는 다음 메서드를 **선택적으로** 구현한다(없으면 호출되지 않음):
  `_enter(msg: Dictionary)`, `_exit()`, `_update(delta)`, `_physics_update(delta)`.
- StateMachine은 `_process`/`_physics_process`에서 현재 상태의 `_update`/`_physics_update`로 위임한다.
- 상태 전환은 `transition_to(state_name: String, msg: Dictionary = {})`로 한다. 이전 상태의
  `_exit()` → 새 상태의 `_enter(msg)` 순으로 호출하고 `state_changed(from, to)` 시그널을 emit한다.

### 사용 예

```gdscript
# 어떤 상태 노드 안에서, 입력에 따라 전환
func _update(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		get_parent().transition_to("Attack")

# 외부에서 전환 로그를 듣고 싶을 때
state_machine.state_changed.connect(func(from, to): print(from, " -> ", to))
```

> 상세 동작은 `state_machine.gd`의 주석(인터페이스 설명)을 참조한다. Player의 이동 로직과 결합하면
> Idle/Walk/Attack 같은 상태 전이를 깔끔하게 표현할 수 있다(기본 Player는 단순 이동만 구현).

---

## 7. 전체 데이터 흐름 한눈에

```
입력(WASD/화살표, 마우스)
        │
        ▼
   [main.gd] ── _unhandled_input ──► object_layer.local_to_map(...)  ──► EventBus.tile_clicked.emit(cell)
        │
        ▼
   [player.gd] ── _physics_process ── Input.get_vector(...) ─► velocity ─► move_and_slide()
        │                                                                      │
        └─ _ready: EventBus.player_spawned.emit(self)                          ▼
                                                            World(y_sort) 안에서 ObjectLayer 타일과
                                                            화면 Y 기준으로 깊이 정렬되어 렌더링

   상태 변경:  [GameState].set_paused(true) ─► get_tree().paused ─► EventBus.game_paused.emit(true)
                                                                          │
                                                                          ▼
                                                              구독한 노드들(UI 등)이 반응
```

---

## 8. 확장 가이드 — 새 코드를 어디에 둘 것인가

### 새 엔티티 추가 (예: Enemy)

1. `src/entities/enemy/` 폴더 생성.
2. `enemy.gd`(`class_name Enemy extends CharacterBody2D` 등)와 `enemy.tscn`을 한 폴더에 둔다.
3. 깊이 정렬이 필요하면 `World`(y_sort 컨테이너) 아래에 인스턴스로 배치한다.
4. 등장/사망 등은 EventBus에 시그널을 추가해 알린다(아래 "새 시그널" 참조).
5. 상태가 복잡하면 `StateMachine` 노드를 엔티티 씬에 자식으로 붙인다.

### 새 시스템 추가 (예: Inventory, Pathfinding)

- 상태가 거의 없는 순수 도구·계산기 → `src/systems/`에 `class_name`을 가진 스크립트로.
- 게임 전역에서 단 하나만 존재해야 하는 매니저(예: AudioManager) → `src/autoload/`에 만들고
  `project.godot`의 autoload에 등록.

### 새 시그널 추가

- `event_bus.gd`에 `signal ...` 한 줄 추가 → 발행 측에서 `EventBus.새시그널.emit(...)`,
  구독 측에서 `EventBus.새시그널.connect(...)`. 발행/구독 양쪽이 서로를 몰라도 되므로
  결합도가 낮게 유지된다.

### 새 씬(화면) 추가 (예: 메뉴, 다른 맵)

- 실행 가능한 화면 단위는 `scenes/`에 `xxx.tscn` + `xxx.gd`로 둔다.
- 아이소 월드가 필요하면 `main.tscn`의 트리 구조(World → GroundLayer/ObjectLayer/Player)를
  본떠 만든다. `/new-iso-scene` 커맨드가 이 스캐폴딩을 돕는다.

### 새 테스트 추가

- `test/unit/`(또는 기능별 하위 폴더)에 `*_test.gd`(`extends GdUnitTestSuite`)로 추가.
- `iso_utils_test.gd`를 본보기로 삼는다. 실행은 `/godot-test` 커맨드 또는 GdUnit4 패널에서 한다.

### 확장 시 지켜야 할 원칙

- **노드 직접 참조보다 EventBus 우선**: 횡단 관심사(사망·점수·일시정지 등)는 시그널로 푼다.
- **런타임 셀 좌표는 TileMapLayer 메서드 우선**, 타일셋 독립 계산만 IsoUtils로.
- **깊이가 중요한 노드는 반드시 같은 Y-sort 컨테이너(World) 아래**에 두고, 비-Y-sort 레이어와는
  `z_index`로 그룹을 분리한다.
- **네이밍/구조 규약**은 `godot-project-conventions` 스킬과 `CLAUDE.md`를 따른다.
