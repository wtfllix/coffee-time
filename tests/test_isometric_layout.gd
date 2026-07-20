extends SceneTree

## 10×10 紧凑等距可玩灰盒的无窗口自动化测试。
##
## 运行：godot4 --headless --path . --script tests/test_isometric_layout.gd
## 预期：输出 [PASS]，进程退出码为 0。

const IsometricCafeScript := preload("res://scripts/art_tests/isometric_interior_blockout.gd")
const CON023_MANIFEST_PATH := "res://assets/candidates/warm_cabin/generate2dmap_v4/warm_cabin-structure.json"

var failure_count: int = 0


func _init() -> void:
	var cafe: Control = IsometricCafeScript.new()
	root.add_child(cafe)
	cafe._build_pathfinder()

	_check(cafe.ROOM_GRID_SIZE == Vector2i(10, 10), "room uses a 10x10 logical square")
	var back: Vector2 = cafe._iso(Vector2.ZERO)
	var right: Vector2 = cafe._iso(Vector2(10.0, 0.0))
	var left: Vector2 = cafe._iso(Vector2(0.0, 10.0))
	_check(is_equal_approx(back.distance_to(right), back.distance_to(left)), "isometric axes have equal projected length")
	_check(is_equal_approx(right.x - back.x, back.x - left.x), "square projection is left-right symmetric")
	_check(is_equal_approx(right.y, left.y), "square side corners share the same screen height")
	_check(is_equal_approx(left.distance_to(right), 560.0), "floor fills 560 pixels of the 640-pixel canvas")
	var front: Vector2 = cafe._iso(Vector2(10.0, 10.0))
	_check(is_equal_approx(front.y - back.y, 280.0), "floor provides 280 pixels of visible depth")
	_check(is_equal_approx(cafe.WALL_HEIGHT_PX, 122.0), "wall height uses the revised 122-pixel calibration")
	_check(
		cafe.FLOOR_WALL_SEAM_OVERLAP_PX > 0.0
		and cafe.FLOOR_WALL_SEAM_OVERLAP_PX < cafe.TILE_HALF_HEIGHT_PX,
		"floor-wall seam overlap stays positive and below one half-tile"
	)
	_check(cafe.WALL_HEIGHT_PX / 280.0 > 0.43, "wall height exceeds 43 percent of floor depth")
	_check(back.y - cafe.WALL_HEIGHT_PX >= 0.0, "wall cap remains inside the canvas")
	_check(front.y <= cafe.DESIGN_SIZE_PX.y, "front floor corner remains inside the canvas")
	var floor_uvs: PackedVector2Array = cafe._get_con022_floor_uvs()
	_check(floor_uvs.size() == 4, "CON-022 floor exposes four normalized UV corners")
	for floor_uv: Vector2 in floor_uvs:
		_check(
			floor_uv.x >= 0.0 and floor_uv.x <= 1.0 and floor_uv.y >= 0.0 and floor_uv.y <= 1.0,
			"CON-022 floor UV %s stays within normalized texture space" % floor_uv
		)
	var floor_center_uv: Vector2 = cafe._get_con022_floor_uv(Vector2(5.0, 5.0))
	var corner_average := (floor_uvs[0] + floor_uvs[1] + floor_uvs[2] + floor_uvs[3]) * 0.25
	_check(floor_center_uv.is_equal_approx(corner_average), "CON-022 floor center uses bilinear grid mapping")
	_check(cafe.USE_CON023_STRUCTURE_PREVIEW, "CON-023 unified room shell is active in the isolated F6 scene")
	_check(cafe.CON023_ROOM_SHELL_TEXTURE.get_size() == Vector2(640.0, 420.0), "CON-023 texture matches the 640x420 canvas")
	_check(FileAccess.file_exists(CON023_MANIFEST_PATH), "CON-023 structure manifest exists")
	var manifest_text := FileAccess.get_file_as_string(CON023_MANIFEST_PATH)
	var manifest: Dictionary = JSON.parse_string(manifest_text)
	_check(not manifest.is_empty(), "CON-023 structure manifest parses")
	if not manifest.is_empty():
		_check(manifest["candidate_id"] == "CON-023", "manifest identifies CON-023")
		_check(manifest["projection"]["wall_height_px"] == 122, "manifest matches the locked wall height")
		_check(
			manifest["source"]["floor_generated_image"].ends_with("warm_cabin-floor-style-source-v3.png"),
			"manifest selects the approved floor-style v3 source"
		)
		_check(
			manifest["source"]["wall_generated_image"].ends_with("warm_cabin-room-shell-source-v2.png"),
			"manifest preserves the accepted wall source"
		)
		var manifest_room_grid: Dictionary = manifest["projection"]["room_grid"]
		_check(
			is_equal_approx(float(manifest_room_grid["width"]), 10.0)
			and is_equal_approx(float(manifest_room_grid["height"]), 10.0),
			"manifest records the 10x10 logical room"
		)
		for layer: Dictionary in manifest["layers"]:
			_check(FileAccess.file_exists(layer["path"]), "manifest layer %s exists" % layer["id"])
	var round_trip_grid: Vector2 = cafe._design_to_grid(cafe._iso(Vector2(6.5, 4.5)))
	_check(round_trip_grid.is_equal_approx(Vector2(6.5, 4.5)), "screen-to-grid inverse projection round-trips")
	for fireplace_cell: Vector2i in [Vector2i(8, 0), Vector2i(9, 0), Vector2i(8, 1), Vector2i(9, 1)]:
		_check(cafe.pathfinder.is_point_solid(fireplace_cell), "the full 2x2 fireplace footprint blocks cell %s" % fireplace_cell)

	var seats: Array[Vector2] = cafe._get_seat_grid_positions()
	_check(seats.size() == 8, "layout exposes eight seats")
	var start_cell: Vector2i = cafe._grid_to_cell(cafe.player_grid_position)
	for index in range(seats.size()):
		var seat_cell: Vector2i = cafe._grid_to_cell(seats[index])
		if index in cafe.CUSTOMER_SEAT_INDICES:
			_check(cafe.pathfinder.is_point_solid(seat_cell), "customer seat %d blocks pathfinding" % index)
		else:
			_check(not cafe.pathfinder.is_point_solid(seat_cell), "free seat %d remains walkable" % index)
			var path: Array[Vector2i] = cafe.pathfinder.get_id_path(start_cell, seat_cell)
			_check(not path.is_empty(), "free seat %d is reachable from the entrance" % index)

	cafe._request_move_to_grid(Vector2(4.5, 8.5))
	_check(not cafe.current_path.is_empty(), "a legal floor click creates a movement path")
	cafe.current_path.clear()
	var fire_center: Vector2 = cafe._iso(cafe.FIRE_GRID_CENTER) - Vector2(0.0, cafe.FIRE_LIFT_PX)
	_check(cafe._try_reject_landmark_visual(fire_center), "visible fireplace and flame reject clicks before floor projection")
	_check(cafe.current_path.is_empty(), "clicking the elevated fireplace visual does not create a floor path")

	if failure_count > 0:
		quit(1)
		return
	print("[PASS] 10x10 isometric layout is symmetric; seats are reachable and the full fireplace footprint is solid.")
	quit(0)


func _check(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("[FAIL] %s" % description)
	failure_count += 1
