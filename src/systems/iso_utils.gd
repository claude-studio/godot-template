class_name IsoUtils
extends RefCounted
## 아이소메트릭 좌표 변환 헬퍼. 모든 메서드 static.
## 표준 2:1 아이소(타일 폭 = 높이 * 2)를 기본 가정하되 tile_size 인자로 일반화한다.
##
## [b]중요[/b]: 런타임에 실제 TileMapLayer의 셀 변환이 필요하면
## TileMapLayer.local_to_map() / map_to_local() 를 우선 사용하라.
## 두 메서드는 타일셋의 모양(아이소/사각/육각)과 오프셋·정렬축을 모두 반영하므로
## 여기 구현보다 정확하다. 본 클래스는 타일셋이 없는 상황의 순수 계산·테스트·UI 보조용이다.
##
## 표준 아이소 수식:
##   screen.x = (cart.x - cart.y) * (tile_size.x / 2)
##   screen.y = (cart.x + cart.y) * (tile_size.y / 2)


## 직교(논리 그리드) 좌표를 아이소 스크린 픽셀로 변환한다.
static func cart_to_iso(cart: Vector2, tile_size: Vector2) -> Vector2:
	return Vector2(
		(cart.x - cart.y) * (tile_size.x / 2.0),
		(cart.x + cart.y) * (tile_size.y / 2.0)
	)


## 아이소 스크린 픽셀을 직교(논리 그리드) 좌표로 변환한다. cart_to_iso의 역연산.
static func iso_to_cart(iso: Vector2, tile_size: Vector2) -> Vector2:
	var half_w: float = tile_size.x / 2.0
	var half_h: float = tile_size.y / 2.0
	# 위 수식의 연립방정식을 역으로 풀어낸 결과.
	return Vector2(
		(iso.x / half_w + iso.y / half_h) / 2.0,
		(iso.y / half_h - iso.x / half_w) / 2.0
	)


## 셀(정수) 좌표를 스크린 픽셀(타일 중심)로 변환한다.
## 런타임에는 TileMapLayer.map_to_local()을 우선 사용하라.
static func map_to_screen(cell: Vector2i, tile_size: Vector2) -> Vector2:
	return cart_to_iso(Vector2(cell), tile_size)


## 스크린 픽셀을 가장 가까운 셀 중심 좌표로 변환한다(반올림).
## 셀 영역 포함 판정이 아니므로, 런타임에는 TileMapLayer.local_to_map()을 우선 사용하라.
static func screen_to_map(screen: Vector2, tile_size: Vector2) -> Vector2i:
	var cart: Vector2 = iso_to_cart(screen, tile_size)
	return Vector2i(roundi(cart.x), roundi(cart.y))


## Y-sort 보조용 깊이값. 화면 위쪽(작은 x+y)일수록 먼저, 아래쪽일수록 나중에 그려진다.
## 값이 클수록 카메라에 가깝다(앞쪽).
static func depth(cell: Vector2i) -> int:
	return cell.x + cell.y
