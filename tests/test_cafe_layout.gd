extends SceneTree

## 1920×1080 显示器下的咖啡店布局测试。
## 窗口高度按计划取约 25%，因此测试画布为 1920×270。

const CafePrototypeScript := preload("res://scripts/cafe/cafe_prototype.gd")

var failure_count: int = 0


func _init() -> void:
	var cafe: Control = CafePrototypeScript.new()
	cafe.set_size(Vector2(1920.0, 270.0))
	root.add_child(cafe)
	cafe._rebuild_layout()

	var table_rects: Array[Rect2] = cafe._get_table_rects()
	var seat_points: Array[Vector2] = cafe._get_seat_points()
	var customer_seats: Array[int] = cafe.get_customer_seat_indices()
	_check(table_rects.size() == 3, "layout has three tables")
	_check(seat_points.size() == 8, "layout exposes eight seats")
	_check(customer_seats.size() == 2, "two placeholder customers occupy seats")
	_check(cafe.seat_occupancy.get_player_accessible_seat_count() == 6, "six seats remain available to the player")
	_check(table_rects[1].end.x > 1600.0, "right table uses the 1920px width")

	var start_cell: Vector2i = cafe._world_to_cell(cafe.player_position)
	for index in range(seat_points.size()):
		var seat_cell: Vector2i = cafe._world_to_cell(seat_points[index])
		if customer_seats.has(index):
			_check(cafe.pathfinder.is_point_solid(seat_cell), "customer seat %d blocks pathfinding" % index)
			_check(not cafe.confirm_seated(index), "player cannot sit in customer seat %d" % index)
		else:
			_check(not cafe.pathfinder.is_point_solid(seat_cell), "free seat %d is not solid" % index)
			var path: PackedVector2Array = cafe.pathfinder.get_point_path(start_cell, seat_cell)
			_check(not path.is_empty(), "free seat %d is reachable from entrance" % index)

	if failure_count > 0:
		quit(1)
		return
	print("[PASS] 1920x270 layout keeps six free seats reachable and two customer seats blocked.")
	quit(0)


func _check(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("[FAIL] %s" % description)
	failure_count += 1
