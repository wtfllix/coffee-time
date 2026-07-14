extends Control

## 色块咖啡店与点击移动原型。
##
## 输入：咖啡店区域内的鼠标左键点击。
## 输出：status_changed，用于向工具栏解释当前行为。
## 依赖：Godot 4.7 的 AStarGrid2D；由 res://scripts/core/main.gd 创建。
##
## 当前边界：
## - 使用程序绘制占位画面，不包含正式像素素材。
## - 订单规则由 res://scripts/orders/order_controller.gd 管理，本脚本只负责空间交互。

## 发送方：本场景；接收方：res://scripts/ui/prototype_toolbar.gd。
signal status_changed(message: String)

## 发送方：本场景；接收方：res://scripts/core/main.gd。
## index 只用于区分座位；其他交互传入 -1。
signal interaction_requested(kind: StringName, index: int)

## 寻路网格边长，单位：像素。
const GRID_SIZE: float = 32.0

## 玩家移动速度，单位：像素/秒。
const PLAYER_SPEED: float = 180.0

## 玩家绘制半径，单位：像素。
const PLAYER_RADIUS: float = 12.0

const COLOR_BACKGROUND := Color("#d8b88d")
const COLOR_FLOOR := Color("#c99762")
const COLOR_BACK_WALL := Color("#ead8b9")
const COLOR_COUNTER := Color("#76523a")
const COLOR_COUNTER_TOP := Color("#a8784f")
const COLOR_TABLE := Color("#8f6243")
const COLOR_CHAIR := Color("#59705c")
const COLOR_PLAYER := Color("#3f6f78")
const COLOR_PLAYER_HIGHLIGHT := Color("#f2d6a2")
const COLOR_TARGET := Color("#fff0b8")
const COLOR_DRINK := Color("#f3e1bd")
const COLOR_BUBBLE := Color("#fff7df")

var pathfinder := AStarGrid2D.new()
var grid_dimensions := Vector2i.ZERO
var obstacle_rects: Array[Rect2] = []
var current_path := PackedVector2Array()
var player_position := Vector2.ZERO
var target_position := Vector2.ZERO
var facing_direction := Vector2.DOWN
var layout_ready := false
var pending_interaction: StringName = &""
var pending_interaction_index: int = -1
var current_order_state: StringName = &"idle"
var seated_index: int = -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_rebuild_layout)
	call_deferred("_rebuild_layout")


func _process(delta: float) -> void:
	if current_path.is_empty():
		return

	var next_point := current_path[0]
	var difference := next_point - player_position
	var travel_distance := PLAYER_SPEED * delta

	_update_facing_direction(difference)
	if difference.length() <= travel_distance:
		player_position = next_point
		current_path.remove_at(0)
		if current_path.is_empty():
			_complete_pending_interaction()
	else:
		player_position += difference.normalized() * travel_distance

	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not layout_ready:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _try_request_interaction(event.position):
			accept_event()
			return
		if current_order_state == &"drinking" or current_order_state == &"empty":
			status_changed.emit(tr("饮品还在桌上，请先完成当前饮用状态"))
			accept_event()
			return
		seated_index = -1
		pending_interaction = &""
		pending_interaction_index = -1
		_request_path(event.position)
		accept_event()


func _draw() -> void:
	_draw_room()
	_draw_furniture()
	_draw_order_visuals()
	_draw_target_marker()
	_draw_player()


## 由订单状态机调用，只接收稳定字符串，不依赖它的内部枚举数字。
func set_order_state(state_name: StringName) -> void:
	current_order_state = state_name
	queue_redraw()


## 角色抵达座位后固定到座椅点，避免路径格中心造成视觉漂移。
func confirm_seated(index: int) -> void:
	var seat_points := _get_seat_points()
	if index < 0 or index >= seat_points.size():
		return
	seated_index = index
	player_position = seat_points[index]
	facing_direction = Vector2.UP
	queue_redraw()


## 窗口尺寸变化后重建家具矩形和寻路网格。
func _rebuild_layout() -> void:
	if size.x < 320.0 or size.y < 160.0:
		return

	_build_obstacles()
	_build_pathfinder()

	if not layout_ready:
		player_position = Vector2(64.0, size.y - 54.0)
		target_position = player_position
		layout_ready = true
	else:
		player_position.x = clampf(player_position.x, GRID_SIZE, size.x - GRID_SIZE)
		player_position.y = clampf(player_position.y, 116.0, size.y - GRID_SIZE)

	current_path.clear()
	pending_interaction = &""
	pending_interaction_index = -1
	queue_redraw()


func _build_obstacles() -> void:
	obstacle_rects.clear()

	# 左上至中央的长柜台。额外边距给玩家角色留出身体宽度。
	obstacle_rects.append(_get_counter_rect().grow(PLAYER_RADIUS))

	# 两张双人桌和一张共享长桌，位置随窗口宽度变化但保持核心构图。
	for table_rect in _get_table_rects():
		obstacle_rects.append(table_rect.grow(PLAYER_RADIUS))


func _build_pathfinder() -> void:
	grid_dimensions = Vector2i(
		maxi(1, ceili(size.x / GRID_SIZE)),
		maxi(1, ceili(size.y / GRID_SIZE))
	)
	pathfinder.region = Rect2i(Vector2i.ZERO, grid_dimensions)
	pathfinder.cell_size = Vector2(GRID_SIZE, GRID_SIZE)
	pathfinder.offset = Vector2(GRID_SIZE * 0.5, GRID_SIZE * 0.5)
	pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfinder.update()

	for y in range(grid_dimensions.y):
		for x in range(grid_dimensions.x):
			var cell := Vector2i(x, y)
			var point := _cell_to_world(cell)
			var outside_floor := point.y < 112.0 or point.y > size.y - 18.0
			if outside_floor or _is_inside_obstacle(point):
				pathfinder.set_point_solid(cell, true)


func _request_path(clicked_position: Vector2) -> void:
	_request_path_with_context(clicked_position, &"", -1)


func _request_path_with_context(
	clicked_position: Vector2,
	interaction_kind: StringName,
	interaction_index: int
) -> void:
	var start_cell := _world_to_cell(player_position)
	var end_cell := _world_to_cell(clicked_position)

	if not _is_cell_in_bounds(end_cell):
		status_changed.emit(tr("目标在咖啡店范围外"))
		return
	if pathfinder.is_point_solid(end_cell):
		status_changed.emit(tr("家具挡住了这个位置"))
		return

	var candidate_path := pathfinder.get_point_path(start_cell, end_cell)
	if candidate_path.is_empty():
		status_changed.emit(tr("暂时找不到可行走路径"))
		return

	current_path = candidate_path
	pending_interaction = interaction_kind
	pending_interaction_index = interaction_index
	# 路径第一点通常是当前格中心，移除后可以避免角色先倒退到格子中心。
	if not current_path.is_empty():
		current_path.remove_at(0)
	target_position = _cell_to_world(end_cell)
	if current_path.is_empty():
		player_position = target_position
		_complete_pending_interaction()
		queue_redraw()
		return
	status_changed.emit(tr("正在前往目标位置"))
	queue_redraw()


## 识别柜台、取餐、座位和空杯气泡；返回 true 表示点击已被情境交互消费。
func _try_request_interaction(clicked_position: Vector2) -> bool:
	if current_order_state == &"empty" and _get_refill_bubble_rect().has_point(clicked_position):
		interaction_requested.emit(&"dismiss_empty", -1)
		return true
	if current_order_state == &"drinking" or current_order_state == &"empty":
		return false

	var counter_rect := _get_counter_rect()
	var order_zone := Rect2(counter_rect.position, Vector2(counter_rect.size.x * 0.5, counter_rect.size.y))
	var pickup_zone := Rect2(
		Vector2(counter_rect.position.x + counter_rect.size.x * 0.5, counter_rect.position.y),
		Vector2(counter_rect.size.x * 0.5, counter_rect.size.y)
	)

	if order_zone.has_point(clicked_position):
		var approach := Vector2(order_zone.get_center().x, counter_rect.end.y + GRID_SIZE)
		_request_path_with_context(approach, &"order", -1)
		return true
	if pickup_zone.has_point(clicked_position):
		var approach := Vector2(pickup_zone.get_center().x, counter_rect.end.y + GRID_SIZE)
		_request_path_with_context(approach, &"pickup", -1)
		return true

	var table_rects := _get_table_rects()
	var seat_points := _get_seat_points()
	for index in range(seat_points.size()):
		if table_rects[index].grow(18.0).has_point(clicked_position):
			_request_path_with_context(seat_points[index], &"seat", index)
			return true

	return false


func _complete_pending_interaction() -> void:
	if pending_interaction == &"":
		status_changed.emit(tr("已到达目标位置"))
		return

	var completed_kind := pending_interaction
	var completed_index := pending_interaction_index
	pending_interaction = &""
	pending_interaction_index = -1
	interaction_requested.emit(completed_kind, completed_index)


func _update_facing_direction(difference: Vector2) -> void:
	if difference == Vector2.ZERO:
		return
	if absf(difference.x) > absf(difference.y):
		facing_direction = Vector2.RIGHT if difference.x > 0.0 else Vector2.LEFT
	else:
		facing_direction = Vector2.DOWN if difference.y > 0.0 else Vector2.UP


func _world_to_cell(world_position: Vector2) -> Vector2i:
	return Vector2i(
		floori(world_position.x / GRID_SIZE),
		floori(world_position.y / GRID_SIZE)
	)


func _cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell) * GRID_SIZE + Vector2.ONE * GRID_SIZE * 0.5


func _is_cell_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_dimensions.x and cell.y < grid_dimensions.y


func _is_inside_obstacle(point: Vector2) -> bool:
	for obstacle in obstacle_rects:
		if obstacle.has_point(point):
			return true
	return false


func _get_counter_rect() -> Rect2:
	return Rect2(28.0, 54.0, size.x * 0.48, 66.0)


func _get_table_rects() -> Array[Rect2]:
	return [
		Rect2(size.x * 0.58, size.y * 0.44, 96.0, 54.0),
		Rect2(size.x * 0.76, size.y * 0.40, 96.0, 54.0),
		Rect2(size.x * 0.62, size.y * 0.72, 220.0, 48.0),
	]


func _get_seat_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	for table_rect in _get_table_rects():
		var below_table := Vector2(table_rect.get_center().x, table_rect.end.y + 30.0)
		var above_table := Vector2(table_rect.get_center().x, table_rect.position.y - 26.0)
		# 共享长桌靠近画面底部，因此使用上侧座位，避免目标落到窗口外。
		points.append(above_table if below_table.y > size.y - 24.0 else below_table)
	return points


func _get_pickup_cup_position() -> Vector2:
	var counter_rect := _get_counter_rect()
	return Vector2(counter_rect.position.x + counter_rect.size.x * 0.75, counter_rect.end.y - 18.0)


func _get_refill_bubble_rect() -> Rect2:
	return Rect2(player_position + Vector2(18.0, -52.0), Vector2(42.0, 34.0))


func _draw_room() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_BACKGROUND)
	draw_rect(Rect2(0.0, 0.0, size.x, 112.0), COLOR_BACK_WALL)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, 96.0),
		Vector2(size.x, 96.0),
		Vector2(size.x, size.y),
		Vector2(0.0, size.y)
	]), COLOR_FLOOR)

	# 左侧入口只做视觉标记，下一阶段再绑定离店交互。
	draw_rect(Rect2(8.0, size.y - 104.0, 44.0, 86.0), Color("#557765"))
	draw_string(ThemeDB.fallback_font, Vector2(12.0, size.y - 60.0), tr("入口"), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color.WHITE)


func _draw_furniture() -> void:
	var counter_rect := _get_counter_rect()
	draw_rect(counter_rect, COLOR_COUNTER)
	draw_rect(Rect2(counter_rect.position, Vector2(counter_rect.size.x, 16.0)), COLOR_COUNTER_TOP)
	draw_string(ThemeDB.fallback_font, counter_rect.position + Vector2(18.0, 42.0), tr("点单"), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(counter_rect.end.x - 72.0, counter_rect.position.y + 42.0), tr("取餐"), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color.WHITE)

	var table_rects := _get_table_rects()
	_draw_table(table_rects[0], false)
	_draw_table(table_rects[1], false)
	_draw_table(table_rects[2], true)


func _draw_table(table_rect: Rect2, shared: bool) -> void:
	draw_rect(table_rect, COLOR_TABLE)
	var chair_count := 4 if shared else 2
	for index in range(chair_count):
		var ratio := float(index + 1) / float(chair_count + 1)
		var chair_x := table_rect.position.x + table_rect.size.x * ratio
		var chair_y := table_rect.end.y + 10.0
		draw_circle(Vector2(chair_x, chair_y), 8.0, COLOR_CHAIR)


func _draw_order_visuals() -> void:
	if current_order_state == &"ready":
		_draw_cup(_get_pickup_cup_position(), false)
	elif current_order_state == &"carried":
		_draw_cup(player_position + Vector2(18.0, 0.0), false)
	elif current_order_state == &"drinking":
		_draw_cup(player_position + Vector2(22.0, 8.0), false)
	elif current_order_state == &"empty":
		_draw_cup(player_position + Vector2(22.0, 8.0), true)
		var bubble_rect := _get_refill_bubble_rect()
		draw_rect(bubble_rect, COLOR_BUBBLE)
		draw_string(
			ThemeDB.fallback_font,
			bubble_rect.position + Vector2(7.0, 23.0),
			tr("续杯"),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			14,
			COLOR_COUNTER
		)


func _draw_cup(cup_position: Vector2, empty: bool) -> void:
	var fill_color := COLOR_BACKGROUND if empty else COLOR_DRINK
	draw_rect(Rect2(cup_position - Vector2(7.0, 8.0), Vector2(14.0, 16.0)), fill_color)
	draw_arc(cup_position + Vector2(8.0, 0.0), 5.0, -PI * 0.5, PI * 0.5, 8, fill_color, 2.0)


func _draw_target_marker() -> void:
	if current_path.is_empty():
		return
	draw_circle(target_position, 7.0, COLOR_TARGET)
	draw_circle(target_position, 3.0, COLOR_COUNTER)


func _draw_player() -> void:
	# 身体和头部分开绘制，让没有正式素材时也能辨认角色朝向。
	draw_circle(player_position + Vector2(0.0, -12.0), 9.0, COLOR_PLAYER_HIGHLIGHT)
	draw_circle(player_position, PLAYER_RADIUS, COLOR_PLAYER)
	draw_line(player_position, player_position + facing_direction * 14.0, Color.WHITE, 3.0)
