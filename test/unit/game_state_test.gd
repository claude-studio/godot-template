# GdUnit4 addon 설치 필요(addons/gdUnit4). 설치 방법은 docs/SETUP.md 참조.
extends GdUnitTestSuite
## GameState 점수·일시정지 상태와 EventBus 알림 흐름 회귀 테스트.

var _emitted_pauses: Array[bool] = []


func before_test() -> void:
	_reset_game_state()
	_disconnect_game_paused_probe()
	_emitted_pauses.clear()


func after_test() -> void:
	_disconnect_game_paused_probe()
	_emitted_pauses.clear()
	_reset_game_state()


func test_add_score_accumulates_positive_values() -> void:
	GameState.add_score(10)
	GameState.add_score(5)

	assert_int(GameState.score).is_equal(15)


func test_add_score_accumulates_negative_values() -> void:
	GameState.add_score(10)
	GameState.add_score(-4)
	GameState.add_score(-6)

	assert_int(GameState.score).is_equal(0)


func test_set_paused_true_updates_game_state_and_scene_tree() -> void:
	GameState.set_paused(true)

	assert_bool(GameState.is_paused).is_true()
	assert_bool(get_tree().paused).is_true()


func test_set_paused_false_updates_game_state_and_scene_tree() -> void:
	GameState.set_paused(true)
	GameState.set_paused(false)

	assert_bool(GameState.is_paused).is_false()
	assert_bool(get_tree().paused).is_false()


func test_set_paused_emits_game_paused_signal_with_exact_bool_values() -> void:
	EventBus.game_paused.connect(_on_game_paused)

	GameState.set_paused(true)
	GameState.set_paused(false)

	assert_array(_emitted_pauses).is_equal([true, false])


func _reset_game_state() -> void:
	get_tree().paused = false
	GameState.is_paused = false
	GameState.score = 0


func _disconnect_game_paused_probe() -> void:
	if EventBus.game_paused.is_connected(_on_game_paused):
		EventBus.game_paused.disconnect(_on_game_paused)


func _on_game_paused(paused: bool) -> void:
	_emitted_pauses.append(paused)
