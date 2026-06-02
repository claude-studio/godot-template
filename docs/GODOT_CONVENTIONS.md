# Godot 공식 컨벤션 (GDScript Style Guide & Best Practices)

이 문서는 **Godot 공식 문서의 컨벤션·규칙**을 정리한 것이다.
모든 항목은 context7 MCP로 공식 문서(`/godotengine/godot-docs`)를 조회해 검증했다.
이 템플릿에서 코드를 쓸 때는 이 규약을 기본으로 따른다. (이 템플릿 고유의 폴더/네이밍/시그널
규약은 정본 지침 `AGENTS.md`(Claude는 `.claude/CLAUDE.md`가 import, Codex는 직접 읽음)와 `godot-project-conventions` 스킬을 함께 본다.)

> 출처: Godot Docs — *GDScript style guide*, *Static typing in GDScript*, *Key concepts overview*, *Groups*, *Using SceneTree*.
> 실제 코드 작성 시 세부가 불확실하면 context7로 위 문서를 다시 확인한다(추측 금지).

---

## 1. 들여쓰기 · 줄

- 들여쓰기는 **탭(Tab)** 을 쓴다(스페이스 혼용 금지).
- 한 줄은 과도하게 길게 쓰지 않는다(공식 가이드 권장: 100자 기준).
- **함수 사이에는 빈 줄 2개**, 함수 내부의 논리 구획 구분에는 **빈 줄 1개** 를 둔다.

```gdscript
func heal(amount):
	health += amount
	health = min(health, max_health)
	health_changed.emit(health)


func take_damage(amount, effect = null):
	health -= amount
	health = max(0, health)
	health_changed.emit(health)
```

## 2. 네이밍 규약

| 대상 | 규칙 | 예시 |
|------|------|------|
| 클래스(`class_name`) / 노드 / 로드한 스크립트 상수 | **PascalCase** | `class_name PlayerController`, `extends CharacterBody2D`, `const Weapon = preload("res://weapon.gd")` |
| 함수 · 변수 | **snake_case** | `var particle_effect`, `func load_level():` |
| 가상 메서드 · private 함수/변수 | **`_` 접두 + snake_case** | `func _ready():`, `var _counter = 0`, `func _recalculate_path():` |
| 상수 | **CONSTANT_CASE** | `const MAX_SPEED = 200` |
| 시그널 | **snake_case, 과거형(일어난 사건)** | `signal player_spawned(position)`, `signal health_changed(value)` |
| enum 이름 / enum 값 | enum 이름 PascalCase, 값 CONSTANT_CASE | `enum Job { KNIGHT, WIZARD, ROGUE }` |

## 3. 코드 순서 (멤버 배치)

공식 스타일 가이드가 권장하는 파일 내 멤버 순서. 가독성과 일관성을 위해 이 순서를 따른다.

```text
01. @tool, @icon, @static_unload  (애너테이션)
02. class_name
03. extends
04. ## 문서 주석(클래스 설명)

05. signals
06. enums
07. constants
08. static 변수
09. @export 변수
10. 그 외 일반 변수
11. @onready 변수

12. _static_init()
13. 그 외 static 메서드
14. 오버라이드한 내장 가상 메서드:
    _init() → _enter_tree() → _ready() → _process() → _physics_process() → 그 외
15. 오버라이드한 커스텀 메서드
16. 그 외 메서드
17. 내부(inner) 클래스
```

```gdscript
class_name Player
extends CharacterBody2D
## 플레이어 캐릭터.

signal health_changed(value)

enum State { IDLE, RUN, ATTACK }

const MAX_LIVES := 3

@export var speed: float = 180.0
@export var max_health: int = 50

var _health: int  # _ready()에서 max_health로 초기화 (선언부에서 @export 값을 읽지 않는다 — export 값은 인스턴스화 시점에 적용됨)

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_health = max_health


func take_damage(amount: int) -> void:
	_health = max(0, _health - amount)
	health_changed.emit(_health)
```

## 4. 정적 타이핑 (Static Typing)

정적 타입은 버그를 줄이고 에디터 자동완성을 개선한다. 변수·상수·인자·반환에 적용할 수 있다.

- **명시적 타입**: `var damage: float = 10.5`, `const MOVE_SPEED: float = 50.0`, `func sum(a: float = 0.0, b: float = 0.0) -> float:`
- **타입 추론(`:=`)**: 대입과 같은 줄에 타입이 드러날 때 권장 → `var damage := 10.5`
- **반환 타입은 항상 `->` 로 명시**: `func _process(delta: float) -> void:`, `func hit(damage: float) -> bool:`

언제 명시 / 언제 추론?

- 타입이 **모호하면 명시**한다. 예: `health := 0` 은 `int` 로 추론되지만 `float` 를 의도했을 수 있어 모호 → `var health: float = 0.0`.
- 타입이 **분명히 중복이면 추론(`:=`)** 을 쓴다. 예: `var direction: Vector3 = Vector3(1, 2, 3)` 은 중복 → `var direction := Vector3(1, 2, 3)`.
- **`get_node()` 결과는 반드시 타입을 명시**한다. 컴파일러가 추론하지 못해 `Node` 로 떨어진다.

```gdscript
# 권장: 명시
@onready var health_bar: ProgressBar = get_node("UI/LifeBar")

# 또는 as 캐스팅(타입 안전성↑, 단 런타임 불일치 시 조용히 null이 됨)
@onready var health_bar := get_node("UI/LifeBar") as ProgressBar

# 비권장: Node로 추론되어 ProgressBar 멤버 자동완성/검사 불가
@onready var health_bar := get_node("UI/LifeBar")
```

## 5. 포매팅 (공백 · 괄호)

- 연산자 주변과 콤마 뒤에 **공백 1개**. 인덱싱 `[]`·호출 `()` 앞에는 공백을 넣지 않는다.
- 한 줄 딕셔너리는 중괄호 안쪽에 공백을 둔다(배열과 구분): `{ key = "value" }`.

```gdscript
# Good
position.x = 5
position.y = target_position.y + 10
dict["key"] = 5
my_array = [4, 5, 6]
my_dictionary = { key = "value" }
print("foo")

# Bad
position.x=5
position.y = mpos.y+10
dict ["key"] = 5
my_array = [4,5,6]
print ("foo")
```

- **불필요한 괄호는 생략**한다. 괄호는 연산 순서나 멀티라인 래핑에 필요할 때만.

```gdscript
# Good
if is_colliding():
	queue_free()
```

- 긴 조건/삼항은 괄호로 감싸 여러 줄로 나누고, **논리 연산자를 다음 줄 맨 앞**에 두며 이중 들여쓰기한다.

```gdscript
if (
		position.x > 200 and position.x < 400
		and position.y > 300 and position.y < 400
):
	pass
```

- 불리언 연산은 `and` / `or` / `not` 키워드를 쓴다(`&&`/`||`/`!` 대신).

## 6. 아키텍처 베스트 프랙티스

Godot의 4가지 핵심 개념을 중심으로 설계한다.

- **Node(노드)**: 게임의 최소 빌딩 블록.
- **Scene(씬)**: 노드들을 묶어 저장한 트리(재사용 단위). 저장하면 단일 노드처럼 인스턴스화된다.
- **Scene Tree(씬 트리)**: 씬들이 중첩되어 이루는 실행 트리. `get_tree()`로 `SceneTree` 싱글톤 접근(그룹 호출, 일시정지, 종료 등).
- **Signal(시그널)**: 노드가 다른 노드/다른 트리 가지의 사건에 반응하게 하는 이벤트.

원칙:

- **느슨한 결합(decoupling)**: 멀리 떨어진 노드를 직접 경로로 묶지 말고 **시그널**로 통신한다.
  관용적으로 *"아래로는 호출, 위로는 시그널(call down, signal up)"* — 부모는 자식 메서드를 직접 호출해도 되지만,
  자식은 부모/상위를 직접 참조하지 말고 시그널을 **emit** 해 알린다.
- **그룹(Groups)**: 태그처럼 노드를 묶어 `SceneTree`로 그룹 전체에 메서드 호출·조회한다. 대규모 씬의 결합도를 낮추는 데 유용.
- **씬으로 분리할 때**: 독립적으로 재사용·인스턴스화할 단위(플레이어, 적, 투사체, UI 조각)는 별도 씬으로 만든다.
- **autoload(싱글톤)는 절제**해서 쓴다. 진짜 전역적인 것(이 템플릿의 `EventBus`·`GameState`)에만 둔다.
  무거운 로직이나 특정 씬에 종속된 상태는 autoload에 두지 않는다.

## 7. 이 템플릿에서의 적용

- 위 규약은 이 템플릿의 기존 규약(`godot-project-conventions` 스킬)과 일치한다. 충돌이 없다.
- 에디터/CI에서 **GDScript 경고(warnings)** 를 켜두고(특히 정적 타입 관련) 위반을 조기에 잡는다.
- 새 코드 작성·리뷰 시 PR 템플릿의 "규약 준수" 체크와 이 문서를 대조한다.
- API 시그니처가 불확실하면 항상 context7(`/godotengine/godot-docs`)로 확인한 뒤 작성한다.
