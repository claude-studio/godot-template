class_name StateMachine
extends Node
## 노드 기반 유한 상태 기계(FSM). 자식 노드(State)를 상태로 사용한다.
##
## State 인터페이스(덕 타이핑 — 별도 베이스 클래스 없음, 필요한 것만 구현):
##   func _enter(msg: Dictionary) -> void      # 상태 진입 시 1회. msg로 데이터 전달.
##   func _exit() -> void                       # 상태 이탈 시 1회.
##   func _update(delta: float) -> void         # _process마다 호출.
##   func _physics_update(delta: float) -> void # _physics_process마다 호출.
## 상태 전이는 State 내부에서 부모(StateMachine)의 transition_to()를 호출해 수행한다.
##
## 사용법:
##   - StateMachine 노드 아래에 각 상태를 자식 Node로 둔다(예: Idle, Walk).
##   - initial_state에 시작 상태 노드의 NodePath를 지정한다.

## 상태가 바뀔 때 발생. from은 이전 상태 이름, to는 새 상태 이름.
signal state_changed(from: String, to: String)

## 시작 상태 노드의 경로. 비워두면 첫 번째 자식을 사용한다.
@export var initial_state: NodePath

## 현재 활성 상태 노드.
var current_state: Node = null


func _ready() -> void:
	var start: Node = null
	if not initial_state.is_empty():
		start = get_node_or_null(initial_state)
	if start == null and get_child_count() > 0:
		start = get_child(0)
	if start != null:
		current_state = start
		if current_state.has_method("_enter"):
			current_state._enter({})


func _process(delta: float) -> void:
	if current_state != null and current_state.has_method("_update"):
		current_state._update(delta)


func _physics_process(delta: float) -> void:
	if current_state != null and current_state.has_method("_physics_update"):
		current_state._physics_update(delta)


## 이름이 state_name인 자식 상태로 전이한다. msg는 새 상태의 _enter()로 전달된다.
func transition_to(state_name: String, msg: Dictionary = {}) -> void:
	var next: Node = get_node_or_null(NodePath(state_name))
	if next == null:
		push_warning("StateMachine: '%s' 상태를 찾을 수 없습니다." % state_name)
		return
	if next == current_state:
		return

	var from_name: String = current_state.name if current_state != null else ""

	if current_state != null and current_state.has_method("_exit"):
		current_state._exit()

	current_state = next
	if current_state.has_method("_enter"):
		current_state._enter(msg)

	state_changed.emit(from_name, current_state.name)
