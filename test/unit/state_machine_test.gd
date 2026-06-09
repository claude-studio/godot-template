# GdUnit4 addon 설치 필요(addons/gdUnit4). 설치 방법은 docs/SETUP.md 참조.
extends GdUnitTestSuite
## StateMachine 상태 진입, 전이, 위임 동작 회귀 테스트.


func test_initial_state_enters_configured_state() -> void:
	var calls: Array[String] = []
	var machine := StateMachine.new()
	var idle := _make_state("Idle", calls)
	var walk := _make_state("Walk", calls)
	machine.add_child(idle)
	machine.add_child(walk)
	machine.initial_state = NodePath("Walk")

	machine._ready()

	assert_object(machine.current_state).is_same(walk)
	assert_array(calls).is_equal(["Walk:_enter"])
	assert_int(walk.enter_count).is_equal(1)
	assert_dict(walk.last_enter_msg).is_equal({})
	machine.free()


func test_empty_initial_state_enters_first_child() -> void:
	var calls: Array[String] = []
	var machine := StateMachine.new()
	var idle := _make_state("Idle", calls)
	var walk := _make_state("Walk", calls)
	machine.add_child(idle)
	machine.add_child(walk)

	machine._ready()

	assert_object(machine.current_state).is_same(idle)
	assert_array(calls).is_equal(["Idle:_enter"])
	assert_int(idle.enter_count).is_equal(1)
	machine.free()


func test_transition_exits_enters_with_msg_and_emits_signal_in_order() -> void:
	var calls: Array[String] = []
	var machine := StateMachine.new()
	var idle := _make_state("Idle", calls)
	var walk := _make_state("Walk", calls)
	machine.add_child(idle)
	machine.add_child(walk)
	machine.state_changed.connect(func(from: String, to: String) -> void:
		calls.append("signal:%s->%s" % [from, to])
	)
	machine._ready()
	calls.clear()

	machine.transition_to("Walk", { "speed": 2.5, "reason": "input" })

	assert_object(machine.current_state).is_same(walk)
	assert_array(calls).is_equal(["Idle:_exit", "Walk:_enter", "signal:Idle->Walk"])
	assert_int(idle.exit_count).is_equal(1)
	assert_int(walk.enter_count).is_equal(1)
	assert_float(walk.last_enter_msg["speed"]).is_equal_approx(2.5, 0.001)
	assert_str(walk.last_enter_msg["reason"]).is_equal("input")
	machine.free()


func test_transition_to_same_state_is_ignored() -> void:
	var calls: Array[String] = []
	var machine := StateMachine.new()
	var idle := _make_state("Idle", calls)
	machine.add_child(idle)
	machine.state_changed.connect(func(from: String, to: String) -> void:
		calls.append("signal:%s->%s" % [from, to])
	)
	machine._ready()
	calls.clear()

	machine.transition_to("Idle", { "reason": "same" })

	assert_object(machine.current_state).is_same(idle)
	assert_array(calls).is_empty()
	assert_int(idle.enter_count).is_equal(1)
	assert_int(idle.exit_count).is_equal(0)
	machine.free()


func test_transition_to_missing_state_keeps_current_state() -> void:
	var calls: Array[String] = []
	var machine := StateMachine.new()
	var idle := _make_state("Idle", calls)
	machine.add_child(idle)
	machine.state_changed.connect(func(from: String, to: String) -> void:
		calls.append("signal:%s->%s" % [from, to])
	)
	machine._ready()
	calls.clear()

	machine.transition_to("Missing")

	assert_object(machine.current_state).is_same(idle)
	assert_array(calls).is_empty()
	assert_int(idle.enter_count).is_equal(1)
	assert_int(idle.exit_count).is_equal(0)
	machine.free()


func test_process_and_physics_process_delegate_to_current_state() -> void:
	var calls: Array[String] = []
	var machine := StateMachine.new()
	var idle := _make_state("Idle", calls)
	var walk := _make_state("Walk", calls)
	machine.add_child(idle)
	machine.add_child(walk)
	machine._ready()
	machine.transition_to("Walk")
	calls.clear()

	machine._process(0.25)
	machine._physics_process(0.5)

	assert_array(calls).is_equal(["Walk:_update", "Walk:_physics_update"])
	assert_int(idle.update_count).is_equal(0)
	assert_int(idle.physics_update_count).is_equal(0)
	assert_int(walk.update_count).is_equal(1)
	assert_int(walk.physics_update_count).is_equal(1)
	assert_float(walk.last_update_delta).is_equal_approx(0.25, 0.001)
	assert_float(walk.last_physics_delta).is_equal_approx(0.5, 0.001)
	machine.free()


func _make_state(state_name: String, calls: Array[String]) -> ProbeState:
	var state := ProbeState.new()
	state.name = state_name
	state.calls = calls
	return state


class ProbeState extends Node:
	var calls: Array[String] = []
	var enter_count: int = 0
	var exit_count: int = 0
	var update_count: int = 0
	var physics_update_count: int = 0
	var last_enter_msg: Dictionary = {}
	var last_update_delta: float = 0.0
	var last_physics_delta: float = 0.0

	func _enter(msg: Dictionary) -> void:
		enter_count += 1
		last_enter_msg = msg
		calls.append("%s:_enter" % name)

	func _exit() -> void:
		exit_count += 1
		calls.append("%s:_exit" % name)

	func _update(delta: float) -> void:
		update_count += 1
		last_update_delta = delta
		calls.append("%s:_update" % name)

	func _physics_update(delta: float) -> void:
		physics_update_count += 1
		last_physics_delta = delta
		calls.append("%s:_physics_update" % name)
