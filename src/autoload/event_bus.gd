extends Node
## 전역 시그널 허브(autoload "EventBus"). 노드 간 느슨한 결합용.
## class_name 없음 — autoload 이름 EventBus로 어디서나 전역 접근한다.
## (autoload 등록은 project.godot에서 이미 완료)
##
## 사용법:
##   - 발신: EventBus.tile_clicked.emit(cell)
##   - 수신: EventBus.tile_clicked.connect(_on_tile_clicked)
##
## 시그널 추가법:
##   1) 아래에 signal 한 줄을 선언한다(인자에 타입 표기 권장).
##   2) 어떤 상황에 누가 emit하고 누가 connect하는지 주석으로 남긴다.
##   3) 전역 신호만 여기 둔다 — 특정 노드끼리만 쓰는 신호는 해당 노드에 직접 둘 것.

## 플레이어가 씬에 생성(준비)되었을 때. player는 생성된 Player 노드.
@warning_ignore("unused_signal")
signal player_spawned(player: Node)

## 플레이어가 사망했을 때.
@warning_ignore("unused_signal")
signal player_died

## 타일이 클릭되었을 때. cell은 클릭된 셀의 맵 좌표.
@warning_ignore("unused_signal")
signal tile_clicked(cell: Vector2i)

## 게임 일시정지 상태가 바뀌었을 때. paused가 true면 정지.
@warning_ignore("unused_signal")
signal game_paused(paused: bool)
