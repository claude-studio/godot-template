class_name Player
extends CharacterBody2D
## 아이소 8방향 이동 플레이어. 스크린 공간 이동 + Y-sort로 깊이 처리.
##
## 기본 동작은 [b]스크린 공간[/b] 이동이다(입력 방향 = 화면상 이동 방향).
## 아이소 격자 축에 맞춰 움직이고 싶다면 아래 _physics_process의 주석을 참고해
## IsoUtils.cart_to_iso로 입력 벡터를 아이소 축으로 보정하면 된다.

## 이동 속도(픽셀/초).
@export var speed: float = 180.0

## 플레이어 외형 폴리곤(씬의 $Visual).
@onready var visual: Polygon2D = $Visual


func _ready() -> void:
	# 전역 허브에 생성 사실을 알린다(UI·카메라·매니저 등이 느슨하게 반응).
	EventBus.player_spawned.emit(self)


func _physics_process(_delta: float) -> void:
	# 4개 입력 액션으로 정규화된 방향 벡터를 얻는다(데드존을 원형으로 올바르게 처리).
	var direction: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)

	# --- 아이소 축 변환(선택) ------------------------------------------------
	# 입력 벡터를 아이소 스크린 축으로 변환하고 싶다면 IsoUtils를 쓸 수 있다
	# (예시 — 기본은 스크린 공간 이동이라 미사용):
	#   direction = IsoUtils.cart_to_iso(direction, Vector2(2, 1)).normalized()
	# ------------------------------------------------------------------------

	velocity = direction * speed
	# move_and_slide()는 delta를 내부에서 자동 반영한다.
	move_and_slide()
