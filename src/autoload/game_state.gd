extends Node
## 게임 전역 상태(autoload "GameState"). 점수·일시정지 등을 보관한다.
## (autoload 등록은 project.godot에서 이미 완료)
##
## 일시정지/점수 변경 알림은 EventBus 시그널로 전파해 UI 등이 느슨하게 반응하도록 한다.

## 현재 점수.
var score: int = 0

## 게임 일시정지 여부.
var is_paused: bool = false


## 일시정지 상태를 설정한다. SceneTree.paused를 토글하고 EventBus로 알린다.
func set_paused(p: bool) -> void:
	is_paused = p
	get_tree().paused = p
	EventBus.game_paused.emit(p)


## 점수를 n만큼 더한다(음수면 감점).
func add_score(n: int) -> void:
	score += n
