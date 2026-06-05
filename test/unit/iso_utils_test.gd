# GdUnit4 addon 설치 필요(addons/gdUnit4). 설치 방법은 docs/SETUP.md 참조.
# Godot AssetLib 또는 https://github.com/godot-gdunit-labs/gdUnit4 클론 후 addons/gdUnit4 배치.
extends GdUnitTestSuite
## IsoUtils 좌표 변환 라운드트립 검증.

## 표준 2:1 아이소 타일 크기(폭=높이*2).
const TILE_SIZE: Vector2 = Vector2(64, 32)

func test_cart_iso_roundtrip() -> void:
	# 직교 → 아이소 → 직교 변환이 원본과 근사하게 일치하는지 확인.
	var cart: Vector2 = Vector2(3, 5)
	var iso: Vector2 = IsoUtils.cart_to_iso(cart, TILE_SIZE)
	var back: Vector2 = IsoUtils.iso_to_cart(iso, TILE_SIZE)
	# 부동소수 오차를 고려해 근사 비교.
	assert_vector(back).is_equal_approx(cart, Vector2(0.001, 0.001))

func test_depth_ordering() -> void:
	# 깊이값(cell.x + cell.y)이 셀 위치에 따라 단조 증가하는지 확인.
	assert_int(IsoUtils.depth(Vector2i(0, 0))).is_less(IsoUtils.depth(Vector2i(1, 0)))
	assert_int(IsoUtils.depth(Vector2i(1, 0))).is_less(IsoUtils.depth(Vector2i(1, 1)))
	assert_int(IsoUtils.depth(Vector2i(0, 0))).is_equal(0)

func test_map_to_screen_origin() -> void:
	# 원점 셀(0,0)은 스크린 원점(0,0)으로 변환되어야 한다.
	var origin: Vector2 = IsoUtils.map_to_screen(Vector2i(0, 0), TILE_SIZE)
	assert_vector(origin).is_equal_approx(Vector2.ZERO, Vector2(0.001, 0.001))
	# 셀 (1,0)은 아이소 축을 따라 오른쪽-아래로 반 타일만큼 이동.
	var cell: Vector2 = IsoUtils.map_to_screen(Vector2i(1, 0), TILE_SIZE)
	assert_float(cell.x).is_equal_approx(32.0, 0.001)
	assert_float(cell.y).is_equal_approx(16.0, 0.001)

func test_screen_to_map_origin_nearby_uses_nearest_cell_center() -> void:
	# 원점 셀 중심 근처의 작은 오프셋은 여전히 원점 셀로 반올림된다.
	var screen: Vector2 = IsoUtils.cart_to_iso(Vector2(0.25, 0.0), TILE_SIZE)
	var cell: Vector2i = IsoUtils.screen_to_map(screen, TILE_SIZE)
	assert_int(cell.x).is_equal(0)
	assert_int(cell.y).is_equal(0)

func test_screen_to_map_half_cell_rounds_to_nearest_center() -> void:
	# 반 셀 이상 이동한 위치는 가장 가까운 셀 중심 정책에 따라 다음 셀로 반올림된다.
	var screen: Vector2 = IsoUtils.cart_to_iso(Vector2(0.5, 0.0), TILE_SIZE)
	var cell: Vector2i = IsoUtils.screen_to_map(screen, TILE_SIZE)
	assert_int(cell.x).is_equal(1)
	assert_int(cell.y).is_equal(0)

func test_screen_to_map_negative_coordinates_round_to_nearest_center() -> void:
	# 음수 좌표도 셀 영역 포함 판정이 아니라 가장 가까운 셀 중심으로 반올림한다.
	var screen: Vector2 = IsoUtils.cart_to_iso(Vector2(-0.51, 0.0), TILE_SIZE)
	var cell: Vector2i = IsoUtils.screen_to_map(screen, TILE_SIZE)
	assert_int(cell.x).is_equal(-1)
	assert_int(cell.y).is_equal(0)

func test_screen_to_map_roundtrips_map_to_screen() -> void:
	# 정수 셀 중심은 map_to_screen() 후 screen_to_map()으로 되돌아와야 한다.
	var expected: Vector2i = Vector2i(-2, 3)
	var screen: Vector2 = IsoUtils.map_to_screen(expected, TILE_SIZE)
	var actual: Vector2i = IsoUtils.screen_to_map(screen, TILE_SIZE)
	assert_int(actual.x).is_equal(expected.x)
	assert_int(actual.y).is_equal(expected.y)
