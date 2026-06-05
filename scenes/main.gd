extends Node2D
## 메인 씬 컨트롤러. 월드/플레이어 배치, 데모 동작을 담당한다.
##
## Y-sort 동작 설명 (Godot 규칙: 노드는 [b]같은 z_index끼리만[/b] Y기준 상대 정렬된다):
##   - World는 y_sort_enabled = true 라서 자식들이 화면 y좌표 기준으로 정렬된다.
##     (아래쪽에 있는 노드가 나중에 그려져 위쪽 노드를 가린다 → 깊이감)
##   - ObjectLayer(y_sort_enabled=true)와 Player는 [b]같은 z_index(=0)[/b]라서
##     World의 Y정렬이 둘을 함께 정렬한다 → 캐릭터가 오브젝트 앞/뒤로 자연스럽게 가려진다.
##   - GroundLayer(바닥)는 비 Y-sort + z_index=-1 로, 항상 정렬 그룹 뒤(아래)에 깔린다.
##     (z_index가 낮으면 Y와 무관하게 항상 뒤에 그려짐 → 캐릭터가 바닥 밑으로 가라앉지 않음)
##   - 핵심: 함께 정렬할 노드는 z_index를 같게, 항상 뒤로 보낼 바닥만 더 낮은 z_index로 둔다.

@onready var world: Node2D = $World
@onready var ground_layer: TileMapLayer = $World/GroundLayer
@onready var object_layer: TileMapLayer = $World/ObjectLayer
@onready var player: Player = $World/Player
@onready var hint: Label = $CanvasLayer/Hint


func _unhandled_input(event: InputEvent) -> void:
	# 좌클릭 시, 클릭한 위치가 속한 ObjectLayer의 셀 좌표를 구해 출력·방송한다.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 전역 마우스 좌표를 ObjectLayer의 로컬 좌표로 변환한 뒤 셀 좌표로 매핑한다.
		# (TileSet을 아이소로 설정해 연결하면 아이소 셀 좌표가 반환된다. TileSet 미할당 상태에서는 셀 좌표가 보장되지 않으니, 데모 동작 확인 전 TileSet을 할당하라.)
		if object_layer.tile_set == null:
			return  # TileSet 미할당 시 좌표 변환을 건너뛴다.

		var local_pos: Vector2 = object_layer.to_local(get_global_mouse_position())
		var cell: Vector2i = object_layer.local_to_map(local_pos)
		print("클릭한 타일 셀: ", cell)
		EventBus.tile_clicked.emit(cell)
