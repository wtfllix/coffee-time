extends Control

## 紧凑型等距室内咖啡店可玩灰盒。
##
## 输入：当前预览窗口尺寸与鼠标左键点击；以 640×420 像素为设计基准统一缩放。
## 输出：无屋顶、两面剖开的室内微缩空间，包含入口、双店员柜台、
## 两张小桌、四人共享桌、壁炉、窗户及玩家/NPC 比例参考。
## 依赖：现有核心循环、暖木屋功能分区与 CON-023 统一结构底图；仅供
## res://scenes/art_tests/isometric_interior_blockout.tscn 使用。
##
## 该脚本实现逻辑方格 A*、等距逆投影、家具阻挡和座位目标；订单仍由后续
## 阶段接入。CON-023 只包含稳定墙地结构，不进入正式主场景。

## 发送方：本场景；接收方：后续紧凑窗口工具栏。
signal status_changed(message: String)

## 紧凑灰盒设计尺寸，单位：像素。
const DESIGN_SIZE_PX := Vector2(640.0, 420.0)

## 独立运行灰盒时使用的原生窗口尺寸，单位：像素。
const PREVIEW_WINDOW_SIZE_PX := Vector2i(640, 420)

## CON-022 复用 CON-021 清理后的 RGBA 地板与高分辨率透明墙体，并按锁定几何分别映射。
## 家具、角色、黑板、碰撞与交互仍由独立程序层负责。
const CON022_FLOOR_SOURCE_TEXTURE: Texture2D = preload(
	"res://assets/candidates/warm_cabin/generate2dmap_v2/warm_cabin-base.png"
)
const CON022_WALLS_SOURCE_TEXTURE: Texture2D = preload(
	"res://assets/candidates/warm_cabin/generate2dmap_v2/warm_cabin-walls-source-clean.png"
)
const CON023_ROOM_SHELL_TEXTURE: Texture2D = preload(
	"res://assets/candidates/warm_cabin/generate2dmap_v4/warm_cabin-room-shell-floor-v3-640x420.png"
)

## 是否在独立 F6 场景中预览 CON-023；正式主场景不引用此开关。
const USE_CON023_STRUCTURE_PREVIEW: bool = true

## CON-022 已因墙地源素材不匹配而停止使用；保留开关便于回看失败原因。
## 新候选通过 Windows 视觉确认前，独立 F6 场景恢复程序结构灰盒。
const USE_CON022_STRUCTURE_PREVIEW: bool = false

## 等距地面单元在屏幕上的半宽与半高，单位：像素。
## 28×14 保持严格 2:1，同时让房间接近概念图的满画布构图。
const TILE_HALF_WIDTH_PX: float = 28.0
const TILE_HALF_HEIGHT_PX: float = 14.0

## 房间网格尺寸，单位：逻辑格。
const ROOM_GRID_SIZE := Vector2i(10, 10)

## 地面后角在设计画布中的位置，单位：像素。
const ROOM_ORIGIN_PX := Vector2(320.0, 125.0)

## 墙体屏幕高度，单位：像素。
const WALL_HEIGHT_PX: float = 122.0

## 地板向墙脚下方延伸的屏幕重叠宽度，单位：像素。
## 分层纹理缩放后必须保留少量 bleed，避免墙脚暗色边缘露成黑色楔形。
const FLOOR_WALL_SEAM_OVERLAP_PX: float = 7.0

## 重叠带从地板内部采样的深度，单位：逻辑格。
const FLOOR_WALL_SEAM_SAMPLE_DEPTH_CELLS: float = 0.35

## 墙面窗户与黑板从墙脚向上抬升的距离，单位：像素。
const WALL_DETAIL_LIFT_PX: float = 56.0

## 清理后 RGBA 地板层的四个材质角，顺序为后、右、前、左，单位：源图像素。
## draw_colored_polygon() 需要 0.0–1.0 UV，因此绘制前必须按纹理尺寸归一化。
const CON022_FLOOR_SOURCE_UV_PX: Array[Vector2] = [
	Vector2(320.0, 82.0),
	Vector2(560.0, 202.0),
	Vector2(320.0, 322.0),
	Vector2(80.0, 202.0),
]

## 透明墙体源图的非透明边界，单位：源图像素。
const CON022_WALLS_SOURCE_RECT_PX := Rect2(165.0, 26.0, 1223.0, 549.0)

## 窗户沿墙面等距轴占用的半宽，单位：逻辑格。
const WINDOW_HALF_SPAN_CELLS: float = 0.95

## 窗户外框的半高，单位：像素。
const WINDOW_HALF_HEIGHT_PX: float = 21.0

## 黑板菜单沿墙面等距轴占用的半宽，单位：逻辑格。
const MENU_BOARD_HALF_SPAN_CELLS: float = 0.72

## 黑板菜单外框的半高，单位：像素。
const MENU_BOARD_HALF_HEIGHT_PX: float = 20.0

## 灰盒角色身体高度，单位：像素。
const ACTOR_HEIGHT_PX: float = 31.0

## 玩家在逻辑网格中的移动速度，单位：格/秒。
const PLAYER_SPEED_CELLS_PER_SECOND: float = 3.2

## 座位点击半径，单位：设计像素。
const SEAT_CLICK_RADIUS_PX: float = 19.0

## 两名占位顾客使用的座位索引。
const CUSTOMER_SEAT_INDICES: Array[int] = [1, 5]

## 壁炉主体的逻辑占地起点与尺寸，单位：逻辑格。
const FIREPLACE_GRID_POSITION := Vector2(8.55, 0.65)
const FIREPLACE_GRID_SIZE := Vector2(1.15, 1.25)

## 炉火的绘制中心和可点击半径；半径覆盖炉火及其周边炉身。
const FIRE_GRID_CENTER := Vector2(9.15, 1.3)
const FIRE_LIFT_PX: float = 17.0
const FIREPLACE_VISUAL_HIT_RADIUS_PX: float = 25.0

## 长柜台的灰盒排序锚点使用占地中心，避免最前角让整条柜台覆盖右侧小桌。
const COUNTER_SORT_DEPTH: float = 5.7

const COLOR_VOID := Color("#17171d")
const COLOR_FLOOR_A := Color("#87543d")
const COLOR_FLOOR_B := Color("#754534")
const COLOR_FLOOR_LINE := Color("#4a2b2a")
const COLOR_WALL_LEFT := Color("#684033")
const COLOR_WALL_RIGHT := Color("#79503a")
const COLOR_WALL_TRIM := Color("#352426")
const COLOR_WINDOW := Color("#83beca")
const COLOR_WINDOW_LIGHT := Color("#b5dde0")
const COLOR_COUNTER_TOP := Color("#b77748")
const COLOR_COUNTER_LEFT := Color("#674033")
const COLOR_COUNTER_RIGHT := Color("#7a4936")
const COLOR_TABLE_TOP := Color("#a96943")
const COLOR_TABLE_SIDE := Color("#60392f")
const COLOR_SEAT := Color("#4f6658")
const COLOR_STAFF := Color("#765146")
const COLOR_PLAYER := Color("#4f817a")
const COLOR_CUSTOMER := Color("#61739a")
const COLOR_SKIN := Color("#d8a27d")
const COLOR_FIRE := Color("#eda34f")
const COLOR_PLANT := Color("#55754d")
const COLOR_ORDER := Color("#d6a151")
const COLOR_PICKUP := Color("#69a9a0")
const COLOR_TARGET := Color("#f5ddb0")
const COLOR_OCCUPIED_SEAT := Color("#514947")
const COLOR_STATUS_BACK := Color(0.05, 0.05, 0.07, 0.82)

var pathfinder := AStarGrid2D.new()
var current_path: Array[Vector2i] = []
var player_grid_position := Vector2(1.5, 8.5)
var target_grid_position := Vector2(1.5, 8.5)
var pending_seat_index: int = -1
var seated_index: int = -1
var status_message: String = "CON-022 素材预览：点击地面移动；点击绿色座位入座"
var canvas_scale: float = 1.0
var canvas_offset := Vector2.ZERO


func _ready() -> void:
	# 明确保持紧凑窗口尺寸，避免原生 F6 运行被本地编辑器窗口状态影响。
	get_window().size = PREVIEW_WINDOW_SIZE_PX
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)
	_build_pathfinder()
	queue_redraw()


func _process(delta: float) -> void:
	if current_path.is_empty():
		return
	var next_position := Vector2(current_path[0]) + Vector2.ONE * 0.5
	var difference := next_position - player_grid_position
	var travel_distance := PLAYER_SPEED_CELLS_PER_SECOND * delta
	if difference.length() <= travel_distance:
		player_grid_position = next_position
		current_path.remove_at(0)
		if current_path.is_empty():
			_complete_movement()
	else:
		player_grid_position += difference.normalized() * travel_distance
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	var design_position := (mouse_event.position - canvas_offset) / canvas_scale
	if _try_reject_landmark_visual(design_position):
		accept_event()
		return
	if _try_request_seat(design_position):
		accept_event()
		return
	var clicked_grid := _design_to_grid(design_position)
	_request_move_to_grid(clicked_grid)
	accept_event()


func _draw() -> void:
	canvas_scale = minf(size.x / DESIGN_SIZE_PX.x, size.y / DESIGN_SIZE_PX.y)
	canvas_offset = (size - DESIGN_SIZE_PX * canvas_scale) * 0.5
	draw_set_transform(canvas_offset, 0.0, Vector2.ONE * canvas_scale)
	draw_rect(Rect2(Vector2.ZERO, DESIGN_SIZE_PX), COLOR_VOID)
	_draw_room_shell()
	_draw_wall_details()
	_draw_floor_landmarks()
	_draw_depth_sorted_world()
	_draw_target_marker()
	_draw_status()


func _iso(grid_position: Vector2) -> Vector2:
	return ROOM_ORIGIN_PX + Vector2(
		(grid_position.x - grid_position.y) * TILE_HALF_WIDTH_PX,
		(grid_position.x + grid_position.y) * TILE_HALF_HEIGHT_PX
	)


func _design_to_grid(design_position: Vector2) -> Vector2:
	var difference := design_position - ROOM_ORIGIN_PX
	var horizontal := difference.x / TILE_HALF_WIDTH_PX
	var vertical := difference.y / TILE_HALF_HEIGHT_PX
	return Vector2((horizontal + vertical) * 0.5, (vertical - horizontal) * 0.5)


func _build_pathfinder() -> void:
	pathfinder.region = Rect2i(Vector2i.ZERO, ROOM_GRID_SIZE)
	pathfinder.cell_size = Vector2.ONE
	pathfinder.offset = Vector2.ONE * 0.5
	pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	pathfinder.update()

	for obstacle_cell in _get_obstacle_cells():
		if _is_cell_in_room(obstacle_cell):
			pathfinder.set_point_solid(obstacle_cell, true)

	var seats := _get_seat_grid_positions()
	for customer_index in CUSTOMER_SEAT_INDICES:
		var occupied_cell := _grid_to_cell(seats[customer_index])
		if _is_cell_in_room(occupied_cell):
			pathfinder.set_point_solid(occupied_cell, true)


func _get_obstacle_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	# 柜台占据左后连续区域；工作带位于其墙侧，不属于玩家通道。
	for grid_y in range(1, 7):
		for grid_x in range(1, 3):
			cells.append(Vector2i(grid_x, grid_y))
	# 两张小桌各占一个逻辑格。
	cells.append(Vector2i(4, 2))
	cells.append(Vector2i(7, 2))
	# 共享桌占据 2×3 格，四个座位位于左右外侧。
	for grid_y in range(5, 8):
		for grid_x in range(6, 8):
			cells.append(Vector2i(grid_x, grid_y))
	# 壁炉的绘制底座跨越 2×2 格；四格全部阻挡，避免角色从靠墙一侧穿入炉身。
	for grid_y in range(0, 2):
		for grid_x in range(8, 10):
			cells.append(Vector2i(grid_x, grid_y))
	# 两株植物不可穿行。
	cells.append(Vector2i(8, 3))
	cells.append(Vector2i(2, 7))
	return cells


func _request_move_to_grid(grid_position: Vector2) -> void:
	var end_cell := _grid_to_cell(grid_position)
	if not _is_cell_in_room(end_cell):
		_set_status("目标在咖啡店范围外")
		return
	if pathfinder.is_point_solid(end_cell):
		_set_status("家具或顾客挡住了这个位置")
		return
	var start_cell := _grid_to_cell(player_grid_position)
	var candidate_path := pathfinder.get_id_path(start_cell, end_cell)
	if candidate_path.is_empty():
		_set_status("暂时找不到可行走路径")
		return
	current_path.assign(candidate_path)
	if not current_path.is_empty():
		current_path.remove_at(0)
	target_grid_position = Vector2(end_cell) + Vector2.ONE * 0.5
	seated_index = -1
	pending_seat_index = -1
	_set_status("正在前往目标位置")
	if current_path.is_empty():
		player_grid_position = target_grid_position
		_complete_movement()


func _try_request_seat(design_position: Vector2) -> bool:
	var seats := _get_seat_grid_positions()
	for index in range(seats.size()):
		if design_position.distance_to(_iso(seats[index])) > SEAT_CLICK_RADIUS_PX:
			continue
		if index in CUSTOMER_SEAT_INDICES:
			_set_status("这个座位已有顾客，请选择绿色空座")
			return true
		var seat_cell := _grid_to_cell(seats[index])
		if pathfinder.is_point_solid(seat_cell):
			_set_status("这个座位当前不可达")
			return true
		pending_seat_index = index
		var start_cell := _grid_to_cell(player_grid_position)
		var candidate_path := pathfinder.get_id_path(start_cell, seat_cell)
		if candidate_path.is_empty():
			pending_seat_index = -1
			_set_status("暂时找不到前往座位的路径")
			return true
		current_path.assign(candidate_path)
		if not current_path.is_empty():
			current_path.remove_at(0)
		target_grid_position = Vector2(seat_cell) + Vector2.ONE * 0.5
		_set_status("正在前往座位")
		if current_path.is_empty():
			player_grid_position = target_grid_position
			_complete_movement()
		return true
	return false


func _try_reject_landmark_visual(design_position: Vector2) -> bool:
	# 壁炉是向上抬高的绘制物。若直接逆投影炉火像素，会命中后方地面格；
	# 因此先对可见轮廓做点击命中，并保留底座 A* 阻挡用于绕行。
	var fire_center := _iso(FIRE_GRID_CENTER) - Vector2(0.0, FIRE_LIFT_PX)
	if design_position.distance_to(fire_center) > FIREPLACE_VISUAL_HIT_RADIUS_PX:
		return false
	_set_status("壁炉挡住了这个位置")
	return true


func _complete_movement() -> void:
	if pending_seat_index >= 0:
		seated_index = pending_seat_index
		player_grid_position = _get_seat_grid_positions()[seated_index]
		pending_seat_index = -1
		_set_status("已入座；点击其他地面可以起身")
	else:
		_set_status("已到达目标位置")


func _grid_to_cell(grid_position: Vector2) -> Vector2i:
	return Vector2i(floori(grid_position.x), floori(grid_position.y))


func _is_cell_in_room(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < ROOM_GRID_SIZE.x and cell.y < ROOM_GRID_SIZE.y


func _set_status(message: String) -> void:
	status_message = message
	status_changed.emit(message)
	queue_redraw()


func _draw_room_shell() -> void:
	if USE_CON023_STRUCTURE_PREVIEW:
		draw_texture(CON023_ROOM_SHELL_TEXTURE, Vector2.ZERO)
		return

	var back := _iso(Vector2.ZERO)
	var right := _iso(Vector2(float(ROOM_GRID_SIZE.x), 0.0))
	var front := _iso(Vector2(float(ROOM_GRID_SIZE.x), float(ROOM_GRID_SIZE.y)))
	var left := _iso(Vector2(0.0, float(ROOM_GRID_SIZE.y)))

	# 地面按逻辑格逐块绘制，便于判断等距寻路映射和家具占地。
	for grid_y in range(ROOM_GRID_SIZE.y):
		for grid_x in range(ROOM_GRID_SIZE.x):
			var center := _iso(Vector2(float(grid_x) + 0.5, float(grid_y) + 0.5))
			var color := COLOR_FLOOR_A if (grid_x + grid_y) % 2 == 0 else COLOR_FLOOR_B
			draw_colored_polygon(_diamond(center, TILE_HALF_WIDTH_PX, TILE_HALF_HEIGHT_PX), color)
			draw_polyline(_closed(_diamond(center, TILE_HALF_WIDTH_PX, TILE_HALF_HEIGHT_PX)), COLOR_FLOOR_LINE, 1.0)

	# 候选关闭时才绘制程序墙。候选墙体本身已完整覆盖墙面、墙脚和顶框，
	# 若继续保留程序墙和粗描边，它们会从抗锯齿边缘上下露出形成色块。
	if not USE_CON022_STRUCTURE_PREVIEW:
		draw_colored_polygon(PackedVector2Array([
			back,
			right,
			right - Vector2(0.0, WALL_HEIGHT_PX),
			back - Vector2(0.0, WALL_HEIGHT_PX),
		]), COLOR_WALL_RIGHT)
		draw_colored_polygon(PackedVector2Array([
			back,
			left,
			left - Vector2(0.0, WALL_HEIGHT_PX),
			back - Vector2(0.0, WALL_HEIGHT_PX),
		]), COLOR_WALL_LEFT)
		draw_polyline(PackedVector2Array([left, front, right]), COLOR_WALL_TRIM, 5.0)
		draw_line(
			back - Vector2(0.0, WALL_HEIGHT_PX),
			right - Vector2(0.0, WALL_HEIGHT_PX),
			COLOR_WALL_TRIM,
			4.0
		)
		draw_line(
			back - Vector2(0.0, WALL_HEIGHT_PX),
			left - Vector2(0.0, WALL_HEIGHT_PX),
			COLOR_WALL_TRIM,
			4.0
		)

	# CON-022 从高分辨率源图直接采样到锁定几何。地板按 10×10 逻辑格细分 UV，
	# 墙体使用透明源图边界映射；只保留程序地板作为透明边缘后备。
	# 正确分层是“地板藏到墙后，墙脚最后压住地板”，不能再用程序色带伪造墙脚。
	if USE_CON022_STRUCTURE_PREVIEW:
		var target_walls_rect := Rect2(
			Vector2(left.x, back.y - WALL_HEIGHT_PX),
			Vector2(right.x - left.x, left.y - (back.y - WALL_HEIGHT_PX))
		)
		_draw_con022_floor_texture()
		_draw_con022_floor_wall_seam_overlap()
		draw_texture_rect_region(
			CON022_WALLS_SOURCE_TEXTURE,
			target_walls_rect,
			CON022_WALLS_SOURCE_RECT_PX
		)


func _draw_con022_floor_texture() -> void:
	# 整块四边形只会产生两组三角形插值，无法让非标准源图严格贴合等距轴。
	# 按逻辑格细分后，每个小面都与灰盒格线共享顶点，避免大范围斜向扭曲。
	for grid_y in range(ROOM_GRID_SIZE.y):
		for grid_x in range(ROOM_GRID_SIZE.x):
			var top_left := Vector2(float(grid_x), float(grid_y))
			var top_right := Vector2(float(grid_x + 1), float(grid_y))
			var bottom_right := Vector2(float(grid_x + 1), float(grid_y + 1))
			var bottom_left := Vector2(float(grid_x), float(grid_y + 1))
			var floor_cell := PackedVector2Array([
				_iso(top_left),
				_iso(top_right),
				_iso(bottom_right),
				_iso(bottom_left),
			])
			var cell_uvs := PackedVector2Array([
				_get_con022_floor_uv(top_left),
				_get_con022_floor_uv(top_right),
				_get_con022_floor_uv(bottom_right),
				_get_con022_floor_uv(bottom_left),
			])
			draw_colored_polygon(floor_cell, Color.WHITE, cell_uvs, CON022_FLOOR_SOURCE_TEXTURE)


func _draw_con022_floor_wall_seam_overlap() -> void:
	# 墙体与地板来自不同尺寸的源图，分别缩放后即使数学边界相同，也会因抗锯齿
	# 留下数像素的深色墙脚。沿两条后边复制第一条地板纹理，形成稳定的遮盖带。
	var overlap_lift := Vector2(0.0, FLOOR_WALL_SEAM_OVERLAP_PX)
	for grid_index in range(ROOM_GRID_SIZE.x):
		var right_start := Vector2(float(grid_index), 0.0)
		var right_end := Vector2(float(grid_index + 1), 0.0)
		var right_inner_start := Vector2(right_start.x, FLOOR_WALL_SEAM_SAMPLE_DEPTH_CELLS)
		var right_inner_end := Vector2(right_end.x, FLOOR_WALL_SEAM_SAMPLE_DEPTH_CELLS)
		draw_colored_polygon(
			PackedVector2Array([
				_iso(right_start) - overlap_lift,
				_iso(right_end) - overlap_lift,
				_iso(right_end),
				_iso(right_start),
			]),
			Color.WHITE,
			PackedVector2Array([
				_get_con022_floor_uv(right_start),
				_get_con022_floor_uv(right_end),
				_get_con022_floor_uv(right_inner_end),
				_get_con022_floor_uv(right_inner_start),
			]),
			CON022_FLOOR_SOURCE_TEXTURE
		)

	for grid_index in range(ROOM_GRID_SIZE.y):
		var left_start := Vector2(0.0, float(grid_index))
		var left_end := Vector2(0.0, float(grid_index + 1))
		var left_inner_start := Vector2(FLOOR_WALL_SEAM_SAMPLE_DEPTH_CELLS, left_start.y)
		var left_inner_end := Vector2(FLOOR_WALL_SEAM_SAMPLE_DEPTH_CELLS, left_end.y)
		draw_colored_polygon(
			PackedVector2Array([
				_iso(left_start) - overlap_lift,
				_iso(left_end) - overlap_lift,
				_iso(left_end),
				_iso(left_start),
			]),
			Color.WHITE,
			PackedVector2Array([
				_get_con022_floor_uv(left_start),
				_get_con022_floor_uv(left_end),
				_get_con022_floor_uv(left_inner_end),
				_get_con022_floor_uv(left_inner_start),
			]),
			CON022_FLOOR_SOURCE_TEXTURE
		)


func _get_con022_floor_uv(grid_position: Vector2) -> Vector2:
	var grid_ratio := grid_position / Vector2(ROOM_GRID_SIZE)
	var source_back := CON022_FLOOR_SOURCE_UV_PX[0]
	var source_right := CON022_FLOOR_SOURCE_UV_PX[1]
	var source_front := CON022_FLOOR_SOURCE_UV_PX[2]
	var source_left := CON022_FLOOR_SOURCE_UV_PX[3]
	var source_back_edge := source_back.lerp(source_right, grid_ratio.x)
	var source_front_edge := source_left.lerp(source_front, grid_ratio.x)
	var source_uv_px := source_back_edge.lerp(source_front_edge, grid_ratio.y)
	return source_uv_px / CON022_FLOOR_SOURCE_TEXTURE.get_size()


func _get_con022_floor_uvs() -> PackedVector2Array:
	return PackedVector2Array([
		_get_con022_floor_uv(Vector2.ZERO),
		_get_con022_floor_uv(Vector2(float(ROOM_GRID_SIZE.x), 0.0)),
		_get_con022_floor_uv(Vector2(ROOM_GRID_SIZE)),
		_get_con022_floor_uv(Vector2(0.0, float(ROOM_GRID_SIZE.y))),
	])


func _draw_wall_details() -> void:
	# CON-022 墙体源图已包含两扇窗；关闭候选时恢复程序窗户。
	# CON-023 统一结构底图同样已包含双窗，不能重复绘制程序窗户。
	if not USE_CON023_STRUCTURE_PREVIEW and not USE_CON022_STRUCTURE_PREVIEW:
		_draw_wall_window(_iso(Vector2(3.0, 0.0)) - Vector2(0.0, WALL_DETAIL_LIFT_PX))
		_draw_wall_window(_iso(Vector2(7.2, 0.0)) - Vector2(0.0, WALL_DETAIL_LIFT_PX))
	# 黑板仍保留程序占位，等待后续独立装饰素材。
	var board_center := _iso(Vector2(0.0, 3.0)) - Vector2(0.0, WALL_DETAIL_LIFT_PX)
	draw_colored_polygon(
		_wall_panel(board_center, Vector2(0.0, 1.0), MENU_BOARD_HALF_SPAN_CELLS, MENU_BOARD_HALF_HEIGHT_PX),
		COLOR_WALL_TRIM
	)
	draw_colored_polygon(
		_wall_panel(board_center, Vector2(0.0, 1.0), MENU_BOARD_HALF_SPAN_CELLS - 0.13, MENU_BOARD_HALF_HEIGHT_PX - 4.0),
		Color("#29322f")
	)


func _draw_counter_zone() -> void:
	# 柜台沿左后墙展开，后方留出两格连续工作带。
	_draw_box(Vector2(1.0, 1.2), Vector2(2.0, 5.0), 28.0, COLOR_COUNTER_TOP, COLOR_COUNTER_LEFT, COLOR_COUNTER_RIGHT)
	# 点单与取餐分离，中间设备块作为视觉间隔。
	_draw_top_marker(Vector2(1.1, 2.0), COLOR_ORDER)
	_draw_top_marker(Vector2(1.1, 5.2), COLOR_PICKUP)
	_draw_box(Vector2(0.7, 3.45), Vector2(0.8, 1.2), 22.0, Color("#707875"), COLOR_WALL_TRIM, COLOR_COUNTER_LEFT)


func _draw_depth_sorted_world() -> void:
	# 所有可与角色产生遮挡的对象共用一个队列。等距纵深为 x + y；
	# 相同纵深时，家具先画、角色后画，保证入座角色不被椅面完全盖住。
	var draw_items: Array[Dictionary] = [
		{"kind": &"counter", "depth": COUNTER_SORT_DEPTH, "layer": 0},
		{"kind": &"round_table", "position": Vector2(4.5, 2.3), "depth": 6.8, "layer": 0},
		{"kind": &"round_table", "position": Vector2(7.15, 2.3), "depth": 9.45, "layer": 0},
		{"kind": &"shared_table", "position": Vector2(6.0, 4.7), "depth": 13.1, "layer": 0},
		{"kind": &"fireplace", "depth": 11.4, "layer": 0},
		{"kind": &"plant", "position": Vector2(8.85, 3.0), "depth": 11.85, "layer": 0},
		{"kind": &"plant", "position": Vector2(2.2, 7.3), "depth": 9.5, "layer": 0},
		{"kind": &"actor", "position": Vector2(0.65, 2.4), "color": COLOR_STAFF, "depth": 3.05, "layer": 1},
		# 长柜台尚未拆段，两名店员在灰盒中都固定于柜台后层。
		{"kind": &"actor", "position": Vector2(0.65, 5.25), "color": COLOR_STAFF, "depth": COUNTER_SORT_DEPTH - 0.01, "layer": 1},
	]
	var seats := _get_seat_grid_positions()
	for index in range(seats.size()):
		var seat_position := seats[index]
		var seat_color := COLOR_OCCUPIED_SEAT if index in CUSTOMER_SEAT_INDICES else COLOR_SEAT
		draw_items.append({"kind": &"seat", "position": seat_position, "color": seat_color, "depth": seat_position.x + seat_position.y, "layer": 0})
	for customer_index in CUSTOMER_SEAT_INDICES:
		var customer_position := seats[customer_index]
		draw_items.append({"kind": &"actor", "position": customer_position, "color": COLOR_CUSTOMER, "depth": customer_position.x + customer_position.y, "layer": 1})
	draw_items.append({"kind": &"actor", "position": player_grid_position, "color": COLOR_PLAYER, "depth": player_grid_position.x + player_grid_position.y, "layer": 1})
	draw_items.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		var first_depth := float(first["depth"])
		var second_depth := float(second["depth"])
		if not is_equal_approx(first_depth, second_depth):
			return first_depth < second_depth
		return int(first["layer"]) < int(second["layer"])
	)
	for item: Dictionary in draw_items:
		_draw_world_item(item)


func _draw_world_item(item: Dictionary) -> void:
	match item["kind"] as StringName:
		&"counter":
			_draw_counter_zone()
		&"round_table":
			_draw_round_table(item["position"] as Vector2)
		&"shared_table":
			_draw_box(item["position"] as Vector2, Vector2(1.6, 3.2), 20.0, COLOR_TABLE_TOP, COLOR_TABLE_SIDE, COLOR_TABLE_SIDE.lightened(0.08))
		&"seat":
			_draw_seat(item["position"] as Vector2, item["color"] as Color)
		&"fireplace":
			_draw_fireplace()
		&"plant":
			_draw_plant(item["position"] as Vector2)
		&"actor":
			_draw_actor(item["position"] as Vector2, item["color"] as Color)


func _get_seat_grid_positions() -> Array[Vector2]:
	return [
		Vector2(3.65, 2.3),
		Vector2(5.55, 2.3),
		Vector2(6.15, 2.3),
		Vector2(8.15, 2.3),
		Vector2(5.25, 5.3),
		Vector2(5.25, 6.7),
		Vector2(8.35, 5.3),
		Vector2(8.35, 6.7),
	]


func _draw_floor_landmarks() -> void:
	# 入口门垫属于地面标记，必须在任何可遮挡对象之前绘制。
	var entrance_center := _iso(Vector2(1.3, 9.35))
	draw_colored_polygon(_diamond(entrance_center, 31.0, 11.0), Color("#415c50"))


func _draw_fireplace() -> void:
	# 壁炉在右后角形成暖色次级焦点。
	_draw_box(FIREPLACE_GRID_POSITION, FIREPLACE_GRID_SIZE, 43.0, Color("#715044"), COLOR_WALL_TRIM, Color("#5e3b34"))
	var fire_center := _iso(FIRE_GRID_CENTER) - Vector2(0.0, FIRE_LIFT_PX)
	draw_circle(fire_center, 8.0, COLOR_FIRE)


func _draw_box(grid_position: Vector2, grid_size: Vector2, height_px: float, top_color: Color, left_color: Color, right_color: Color) -> void:
	var back := _iso(grid_position)
	var right := _iso(grid_position + Vector2(grid_size.x, 0.0))
	var front := _iso(grid_position + grid_size)
	var left := _iso(grid_position + Vector2(0.0, grid_size.y))
	var lift := Vector2(0.0, height_px)
	draw_colored_polygon(PackedVector2Array([left, front, front - lift, left - lift]), left_color)
	draw_colored_polygon(PackedVector2Array([right, front, front - lift, right - lift]), right_color)
	draw_colored_polygon(PackedVector2Array([back - lift, right - lift, front - lift, left - lift]), top_color)
	draw_polyline(_closed(PackedVector2Array([back - lift, right - lift, front - lift, left - lift])), COLOR_WALL_TRIM, 1.5)


func _draw_round_table(grid_position: Vector2) -> void:
	var center := _iso(grid_position) - Vector2(0.0, 16.0)
	draw_colored_polygon(_diamond(center, 31.0, 15.0), COLOR_TABLE_TOP)
	draw_line(center + Vector2(0.0, 15.0), center + Vector2(0.0, 31.0), COLOR_TABLE_SIDE, 6.0)


func _draw_seat(grid_position: Vector2, seat_color: Color) -> void:
	var center := _iso(grid_position) - Vector2(0.0, 7.0)
	draw_colored_polygon(_diamond(center, 16.0, 8.0), seat_color)
	draw_line(center + Vector2(0.0, 8.0), center + Vector2(0.0, 20.0), COLOR_WALL_TRIM, 3.0)


func _draw_actor(grid_position: Vector2, body_color: Color) -> void:
	var feet := _iso(grid_position)
	draw_colored_polygon(PackedVector2Array([
		feet + Vector2(-9.0, -4.0), feet + Vector2(0.0, 1.0),
		feet + Vector2(9.0, -4.0), feet + Vector2(7.0, -ACTOR_HEIGHT_PX),
		feet + Vector2(-7.0, -ACTOR_HEIGHT_PX),
	]), body_color)
	draw_circle(feet + Vector2(0.0, -ACTOR_HEIGHT_PX - 8.0), 8.0, COLOR_SKIN)
	draw_colored_polygon(_diamond(feet + Vector2(0.0, -ACTOR_HEIGHT_PX - 15.0), 9.0, 4.0), COLOR_WALL_TRIM)


func _draw_wall_window(center: Vector2) -> void:
	var wall_axis := Vector2(1.0, 0.0)
	draw_colored_polygon(
		_wall_panel(center, wall_axis, WINDOW_HALF_SPAN_CELLS, WINDOW_HALF_HEIGHT_PX),
		COLOR_WALL_TRIM
	)
	draw_colored_polygon(
		_wall_panel(center, wall_axis, WINDOW_HALF_SPAN_CELLS - 0.13, WINDOW_HALF_HEIGHT_PX - 4.0),
		COLOR_WINDOW
	)
	var wall_step := _iso(wall_axis) - _iso(Vector2.ZERO)
	draw_line(center - Vector2(0.0, WINDOW_HALF_HEIGHT_PX - 4.0), center + Vector2(0.0, WINDOW_HALF_HEIGHT_PX - 4.0), COLOR_WALL_TRIM, 2.0)
	draw_line(
		center - wall_step * (WINDOW_HALF_SPAN_CELLS - 0.13),
		center + wall_step * (WINDOW_HALF_SPAN_CELLS - 0.13),
		COLOR_WINDOW_LIGHT,
		2.0
	)


func _wall_panel(
	center: Vector2,
	wall_axis_grid: Vector2,
	half_span_cells: float,
	half_height_px: float
) -> PackedVector2Array:
	var wall_step := _iso(wall_axis_grid) - _iso(Vector2.ZERO)
	var span := wall_step * half_span_cells
	var vertical := Vector2(0.0, half_height_px)
	return PackedVector2Array([
		center - span - vertical,
		center + span - vertical,
		center + span + vertical,
		center - span + vertical,
	])


func _draw_top_marker(grid_position: Vector2, marker_color: Color) -> void:
	draw_colored_polygon(_diamond(_iso(grid_position) - Vector2(0.0, 30.0), 13.0, 6.0), marker_color)


func _draw_plant(grid_position: Vector2) -> void:
	var base := _iso(grid_position)
	draw_colored_polygon(_diamond(base - Vector2(0.0, 6.0), 12.0, 6.0), COLOR_COUNTER_RIGHT)
	draw_circle(base - Vector2(0.0, 18.0), 10.0, COLOR_PLANT)


func _draw_target_marker() -> void:
	if current_path.is_empty():
		return
	draw_polyline(_closed(_diamond(_iso(target_grid_position), 13.0, 6.5)), COLOR_TARGET, 2.0)


func _draw_status() -> void:
	draw_rect(Rect2(12.0, 390.0, 616.0, 22.0), COLOR_STATUS_BACK)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(22.0, 406.0),
		status_message,
		HORIZONTAL_ALIGNMENT_LEFT,
		596.0,
		13,
		Color("#f0dfc2")
	)


func _diamond(center: Vector2, half_width_px: float, half_height_px: float) -> PackedVector2Array:
	return PackedVector2Array([
		center + Vector2(0.0, -half_height_px),
		center + Vector2(half_width_px, 0.0),
		center + Vector2(0.0, half_height_px),
		center + Vector2(-half_width_px, 0.0),
	])


func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var result := points.duplicate()
	if not result.is_empty():
		result.append(result[0])
	return result
