---
name: godot-project-conventions
description: 이 Godot 템플릿에서 파일을 추가하거나 코드를 작성할 때 따라야 할 폴더 구조·네이밍·시그널 규약
---

# Godot 프로젝트 규약

이 스킬은 본 아이소메트릭 2D 템플릿에서 **새 파일을 추가하거나 코드를 작성할 때** 따라야 하는
폴더 구조·네이밍·코딩·시그널 규약을 정의한다. 모든 산출물은 아래 규칙을 그대로 따른다.

## 1. 폴더 구조와 역할

`res://`는 프로젝트 루트(이 워크트리 루트)를 가리킨다.

```
godot-template/
├── AGENTS.md                # 도구 무관 정본 지침(Codex 등 공용)
├── skills/                  # 공용 스킬(SKILL.md). .claude/skills·.codex/skills·.agents/skills가 심볼릭으로 공유
├── .claude/                 # Claude 연동(CLAUDE.md·settings.json·agents·skills→../skills)
├── .codex/                  # Codex 연동(config.toml·skills→../skills)
├── scenes/                  # 실행 진입점이 되는 상위 씬과 그 컨트롤러 스크립트
│   ├── main.tscn            # 메인 씬(project.godot의 run/main_scene)
│   └── main.gd              # 메인 씬 컨트롤러
├── src/                     # 모든 GDScript 로직
│   ├── autoload/            # 싱글톤(autoload). 전역 시그널/상태
│   │   ├── event_bus.gd     # autoload "EventBus" — 전역 시그널 허브
│   │   └── game_state.gd    # autoload "GameState" — 게임 전역 상태
│   ├── systems/             # 재사용 가능한 시스템/헬퍼(엔티티에 종속되지 않음)
│   │   ├── iso_utils.gd     # class_name IsoUtils — 아이소 좌표 변환(static)
│   │   └── state_machine.gd # class_name StateMachine — 노드 기반 FSM
│   └── entities/            # 게임 오브젝트. 엔티티별 폴더에 스크립트+씬을 함께 둠
│       └── player/
│           ├── player.gd    # class_name Player extends CharacterBody2D
│           └── player.tscn  # Player 씬
├── assets/                  # 이미지·오디오·타일셋 등 리소스(.gitkeep로 빈 폴더 추적)
├── test/                    # GdUnit4 테스트
│   └── unit/
│       └── iso_utils_test.gd
├── docs/                    # SETUP.md, ARCHITECTURE.md 등 문서(한국어)
├── project.godot            # autoload·input·rendering 설정
└── icon.svg                 # 프로젝트 아이콘
```

각 폴더의 책임:

- **scenes/**: 게임의 진입점/화면 단위 씬과 그 컨트롤러. 상위 조립(월드·플레이어 배치)을 담당.
- **src/autoload/**: 프로젝트 전역에서 항상 접근 가능한 싱글톤. 시그널 허브(EventBus)와 상태(GameState)만 둔다. 무거운 로직은 두지 않는다.
- **src/systems/**: 특정 엔티티에 종속되지 않는 재사용 시스템·순수 헬퍼. `IsoUtils`처럼 static 헬퍼이거나 `StateMachine`처럼 범용 컴포넌트.
- **src/entities/**: 플레이어·적·아이템 등 실제 게임 오브젝트. **엔티티 1개 = 폴더 1개**, 그 안에 `.gd`와 `.tscn`을 함께 둔다.
- **assets/**: 비코드 리소스. 빈 상태를 git이 추적하도록 `.gitkeep` 유지.
- **test/**: GdUnit4 테스트 스위트. 단위 테스트는 `test/unit/`.
- **skills/**: 공용 스킬(`SKILL.md`). 지식 스킬 + 워크플로 스킬(`godot-run`·`godot-test`·`new-iso-scene`·`iso-debug`, 슬래시커맨드 겸용). `.claude/skills`·`.codex/skills`가 심볼릭으로 가리켜 Claude·Codex가 공유.
- **.claude/**: Claude Code 전용 연동(CLAUDE.md·settings.json·agents·skills→../skills). 글로벌 설정 없이 동작.
- **.codex/**: Codex CLI 연동(config.toml·skills→../skills).

## 2. 네이밍 규약

| 대상 | 규칙 | 예시 |
|------|------|------|
| 파일명(.gd / .tscn) | `snake_case` | `iso_utils.gd`, `player.tscn`, `state_machine.gd` |
| `class_name` | `PascalCase` | `IsoUtils`, `StateMachine`, `Player` |
| 노드 이름(씬 트리) | `PascalCase` | `World`, `GroundLayer`, `ObjectLayer`, `Player`, `Camera2D` |
| 시그널 | `snake_case`, **과거형(일어난 일)** | `player_died`, `player_spawned`, `tile_clicked` |
| 변수·함수 | `snake_case` | `add_score`, `is_paused`, `tile_size` |
| 상수 | `CONSTANT_CASE` | `MAX_SPEED` |
| private 멤버(변수·함수) | `_` 접두 | `_current_state`, `_update(delta)` |

- 시그널은 "발생한 사건"을 과거형으로 표현한다. `die`가 아니라 `player_died`, `click`이 아니라 `tile_clicked`.
- autoload 스크립트(`event_bus.gd`, `game_state.gd`)는 **`class_name`을 두지 않는다**. autoload 등록 이름(`EventBus`, `GameState`)으로 전역 접근하며, `class_name`과 이름이 충돌하는 것을 피한다.
- 그 외 재사용 타입(`systems/`, `entities/`)은 `class_name`을 부여해 타입으로 참조 가능하게 한다.

## 3. autoload 규약

본 템플릿은 두 개의 autoload만 둔다(`project.godot`에 등록됨).

- **EventBus** (`src/autoload/event_bus.gd`): 전역 시그널 허브. 노드 간 직접 참조 대신 시그널로 느슨하게 결합한다. 새 전역 이벤트는 여기에 `signal`로 선언하고, 발생 측은 `EventBus.<signal>.emit(...)`, 수신 측은 `EventBus.<signal>.connect(...)`로 연결한다.
  - 예시 시그널: `player_spawned(player: Node)`, `player_died`, `tile_clicked(cell: Vector2i)`, `game_paused(paused: bool)`.
- **GameState** (`src/autoload/game_state.gd`): 게임 전역 상태(점수·일시정지 등). 상태 변경 메서드는 필요 시 EventBus로 알림을 발행한다(예: `set_paused`가 `EventBus.game_paused.emit(p)` 호출).

**결합 원칙**: 서로 멀리 떨어진 노드를 연결할 때는 직접 노드 경로(`get_node`)로 묶기보다 **EventBus 시그널을 우선**한다. 부모-자식처럼 가까운 직접 관계는 `@onready`/`@export`로 노드를 참조해도 된다.

## 4. 코딩 규약 (GDScript)

- **정적 타이핑을 적극 사용**한다. 변수·인자·반환 타입을 명시한다.
  - 추론 가능한 지역 변수는 `:=`(타입 추론 대입) 사용 권장: `var cell := tilemap.local_to_map(pos)`.
  - 함수 시그니처는 항상 타입 명시: `func add_score(n: int) -> void:`.
- **들여쓰기는 탭(Tab)** 을 쓴다. 스페이스 혼용 금지.
- `@export`: 에디터에서 조정할 값(예: `@export var speed: float = 180.0`). 인스펙터 노출이 필요한 값에만 사용.
- `@onready`: 씬 트리가 준비된 뒤 접근하는 노드 참조(예: `@onready var sprite: Sprite2D = $Sprite2D`). 노드 경로는 실제 씬 트리와 정확히 일치시킨다.
- 시그널 선언은 타입을 포함한다: `signal tile_clicked(cell: Vector2i)`.
- 주석은 **한국어**로 간결하게. 파일/클래스 설명은 `##` 문서 주석을 쓴다.
- 런타임 셀↔픽셀 변환은 `IsoUtils`의 수식 헬퍼보다 **`TileMapLayer.local_to_map` / `map_to_local`을 우선** 사용한다(타일셋 모양/오프셋을 정확히 반영).

### 공식 GDScript 스타일 가이드 (필수 준수)

위 규칙은 Godot **공식 스타일 가이드**와 일치한다. 공식 컨벤션 전체(코드 순서·정적 타이핑 세부·포매팅·
아키텍처 베스트 프랙티스)는 **`docs/GODOT_CONVENTIONS.md`** 에 정리되어 있다(context7 `/godotengine/godot-docs`로 검증).
특히 다음은 코드 작성 시 반드시 지킨다.

- **멤버 순서**: `@tool` → `class_name` → `extends` → `##문서주석` → signals → enums → constants → static var → `@export` → 일반 var → `@onready` → 메서드(`_init`→`_enter_tree`→`_ready`→`_process`→`_physics_process`→그 외).
- **`get_node()` 결과는 타입을 명시**한다(추론 시 `Node`로 떨어짐): `@onready var bar: ProgressBar = get_node("UI/LifeBar")`.
- 타입이 모호하면 명시, 중복이면 `:=` 추론. 함수 반환은 항상 `->` 명시.
- 함수 사이 빈 줄 2개·내부 1개, 연산자/콤마 뒤 공백 1개, 불필요한 괄호 생략, 불리언은 `and`/`or`/`not`.
- 세부·예시는 `docs/GODOT_CONVENTIONS.md` 참조.

## 5. 새 엔티티/씬 추가 절차

새 게임 오브젝트(예: 적 `Enemy`)를 추가할 때:

1. `src/entities/<entity_name>/` 폴더를 만든다(snake_case).
2. 그 안에 `<entity_name>.gd`와 `<entity_name>.tscn`을 함께 둔다.
3. 스크립트는 `class_name <PascalCase>` + 적절한 베이스(`CharacterBody2D`, `Area2D` 등)로 선언한다.
4. 다른 노드와 통신이 필요하면 직접 참조 대신 **EventBus 시그널**을 추가/사용한다.
5. 움직이는 엔티티는 메인 씬에서 **Y-sort가 켜진 컨테이너 아래**(예: `World`)에 배치해 깊이 정렬에 포함시킨다. 아이소 좌표/Y-sort 세부는 `godot-isometric` 스킬을 참조한다.
6. 검증이 필요한 순수 로직은 `test/unit/`에 GdUnit4 테스트를 추가한다(`gdunit4-testing` 스킬 참조).

새 아이소 씬은 매번 손으로 만들지 말고 **`/new-iso-scene` 커맨드**로 스캐폴딩한다. 이 커맨드는
World(`y_sort_enabled=true`) · GroundLayer(비 Y-sort, `z_index=-1`) · ObjectLayer(`y_sort_enabled=true`, `z_index=0`) ·
Camera2D 구조를 본 템플릿 규약(`scenes/main.tscn`과 동일한 트리)에 맞춰 생성한다. 생성 후 엔티티를 World 아래에 추가하고 컨트롤러 스크립트를 연결하면 된다.

## 6. 씬 파일(.tscn) 규약

- 텍스트 씬 포맷 `format=3`을 쓴다.
- 외부 리소스는 `ext_resource`(`type`+`path`+`id`)로 참조한다. 손으로 작성할 땐 `uid`를 생략해도 path로 로드된다(Godot 4.6 에디터로 저장하면 uid가 기록됨).
- `load_steps`는 **(ext_resource 수 + sub_resource 수 + 1)** 로 맞춰 둔다(Godot 4.6+ 에디터는 기록하지 않지만 남아 있어도 무해·하위호환).
- 노드 이름은 PascalCase, 트리 구조는 컨트롤러 스크립트의 `@onready` 경로와 일치시킨다.

## 7. 스킬·도구 라우팅 (요약)

상황에 따라 아래 스킬/도구를 사용한다(정본은 `AGENTS.md`, Claude는 `.claude/CLAUDE.md`가 이를 import).

| 상황 | 사용할 스킬/도구 |
|------|------------------|
| "뭘 만들지" 기획 초기 | `superpowers:brainstorming` |
| 버그(특히 Y-sort/좌표 변환 막힘) | `superpowers:systematic-debugging` + 템플릿 `/iso-debug` 절차 |
| 전투·인벤토리 등 로직 검증 | `superpowers:test-driven-development` + `gdunit4-testing` 스킬 |
| Godot 최신 API 확인 | **context7 MCP** (`resolve-library-id` → `query-docs`, libraryId `/godotengine/godot-docs`) |
| 에디터 직접 조작(노드/씬/실행/디버그) | **godot MCP** (`godot-mcp-workflow` 스킬) |
| GDScript 패턴(시그널/씬/FSM/최적화) | `game-development` 플러그인의 `godot-gdscript-patterns` 스킬 |
| 아이소 좌표/Y-sort 지식 | 템플릿 `godot-isometric` 스킬 |
