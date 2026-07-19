extends Control

## 温暖木屋主题的 1280×270 分层布局灰盒。
##
## 输入：当前预览窗口尺寸；以 1280×270 像素为设计基准等比映射。
## 输出：入口、双店员工作区、短柜台、两组靠窗桌、四人长桌与通道的程序预览。
## 依赖：DEC-013、DEC-014 与 CON-005；仅供
## res://scenes/art_tests/warm_cabin_layout_blockout.tscn 使用。
##
## 该脚本不实现寻路或订单。灰盒先验证空间和角色尺度，避免把概念图中的
## 插画比例直接带入正式像素素材。

## 设计画布宽度，单位：像素。
const DESIGN_WIDTH_PX: float = 1280.0

## 设计画布高度，单位：像素。
const DESIGN_HEIGHT_PX: float = 270.0

## 代表角色尺寸，单位：像素。
const ACTOR_SIZE_PX := Vector2(32.0, 48.0)

const WALL_FLOOR_Y_PX: float = 104.0
const STAFF_AISLE_BACK_Y_PX: float = 104.0
const STAFF_AISLE_FRONT_Y_PX: float = 146.0
const COUNTER_TOP_FRONT_Y_PX: float = 160.0
const COUNTER_FRONT_BOTTOM_Y_PX: float = 194.0

const COLOR_VOID := Color("#121318")
const COLOR_WALL := Color("#603b2c")
const COLOR_WALL_PANEL := Color("#7a4a32")
const COLOR_BEAM := Color("#2b1b1b")
const COLOR_FLOOR_BACK := Color("#805036")
const COLOR_FLOOR_FRONT := Color("#4a2c28")
const COLOR_STAFF_ZONE := Color("#9a6740")
const COLOR_ROUTE := Color(0.36, 0.72, 0.64, 0.18)
const COLOR_COUNTER_TOP := Color("#b97842")
const COLOR_COUNTER_FRONT := Color("#603628")
const COLOR_COUNTER_TRIM := Color("#342020")
const COLOR_TABLE_TOP := Color("#9d6038")
const COLOR_TABLE_FRONT := Color("#573126")
const COLOR_CHAIR := Color("#425044")
const COLOR_WINDOW := Color("#73b9cc")
const COLOR_WINDOW_SKY := Color("#a8d9df")
const COLOR_PLANT := Color("#46633d")
const COLOR_FIRE := Color("#eea34c")
const COLOR_ACTOR_BODY := Color("#46716c")
const COLOR_BARISTA_BODY := Color("#6f4e43")
const COLOR_SKIN := Color("#d7a078")
const COLOR_ORDER := Color("#d9a354")
const COLOR_PICKUP := Color("#6ca9a0")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var canvas_scale := Vector2(size.x / DESIGN_WIDTH_PX, size.y / DESIGN_HEIGHT_PX)
	draw_set_transform(Vector2.ZERO, 0.0, canvas_scale)
	_draw_shell()
	_draw_staff_area()
	_draw_counter()
	_draw_seating()
	_draw_landmarks()
	_draw_scale_references()
	_draw_routes()


func _draw_shell() -> void:
	draw_rect(Rect2(0.0, 0.0, DESIGN_WIDTH_PX, DESIGN_HEIGHT_PX), COLOR_VOID)
	draw_rect(Rect2(8.0, 8.0, 1264.0, WALL_FLOOR_Y_PX - 8.0), COLOR_WALL)
	draw_rect(Rect2(8.0, 8.0, 1264.0, 10.0), COLOR_BEAM)
	draw_rect(Rect2(8.0, WALL_FLOOR_Y_PX - 6.0, 1264.0, 6.0), COLOR_BEAM)
	for panel_x in range(24, 1280, 96):
		draw_line(Vector2(float(panel_x), 18.0), Vector2(float(panel_x), WALL_FLOOR_Y_PX - 6.0), COLOR_WALL_PANEL, 1.0)

	draw_rect(Rect2(8.0, WALL_FLOOR_Y_PX, 1264.0, DESIGN_HEIGHT_PX - WALL_FLOOR_Y_PX), COLOR_FLOOR_BACK)
	draw_rect(Rect2(8.0, 208.0, 1264.0, 62.0), COLOR_FLOOR_FRONT)
	for floor_y: float in [116.0, 130.0, 148.0, 170.0, 196.0, 228.0, 262.0]:
		draw_line(Vector2(8.0, floor_y), Vector2(1272.0, floor_y), Color(0.28, 0.14, 0.12, 0.45), 1.0)

	# 左侧入口保留完整到店缓冲区，不与柜台碰撞。
	draw_rect(Rect2(34.0, 28.0, 62.0, 76.0), COLOR_BEAM)
	draw_rect(Rect2(41.0, 35.0, 48.0, 69.0), Color("#493027"))
	draw_rect(Rect2(49.0, 43.0, 32.0, 24.0), COLOR_WINDOW)
	draw_rect(Rect2(27.0, 104.0, 76.0, 9.0), Color("#31463d"))

	_draw_window(Rect2(720.0, 28.0, 104.0, 60.0))
	_draw_window(Rect2(930.0, 28.0, 104.0, 60.0))


func _draw_staff_area() -> void:
	# 42 像素深的连续工作带可容纳 32×48 像素店员，并允许沿柜台横向移动。
	draw_rect(Rect2(196.0, STAFF_AISLE_BACK_Y_PX, 390.0, STAFF_AISLE_FRONT_Y_PX - STAFF_AISLE_BACK_Y_PX), COLOR_STAFF_ZONE)
	draw_rect(Rect2(204.0, 88.0, 84.0, 16.0), COLOR_BEAM)
	draw_rect(Rect2(216.0, 92.0, 60.0, 9.0), COLOR_WALL_PANEL)
	draw_rect(Rect2(310.0, 79.0, 92.0, 25.0), COLOR_BEAM)
	draw_rect(Rect2(322.0, 85.0, 68.0, 14.0), Color("#6e7774"))
	draw_rect(Rect2(424.0, 86.0, 72.0, 18.0), COLOR_BEAM)
	for cup_x: float in [434.0, 450.0, 466.0, 482.0]:
		draw_rect(Rect2(cup_x, 90.0, 10.0, 9.0), Color("#d4b18a"))

	# 黑板菜单只保留大轮廓，不绘制不可读的伪文字。
	draw_rect(Rect2(220.0, 26.0, 206.0, 43.0), COLOR_BEAM)
	draw_rect(Rect2(228.0, 34.0, 190.0, 27.0), Color("#26312d"))


func _draw_counter() -> void:
	var counter_rect := Rect2(190.0, STAFF_AISLE_FRONT_Y_PX, 400.0, COUNTER_TOP_FRONT_Y_PX - STAFF_AISLE_FRONT_Y_PX)
	draw_rect(counter_rect, COLOR_COUNTER_TOP)
	draw_rect(Rect2(190.0, COUNTER_TOP_FRONT_Y_PX, 400.0, COUNTER_FRONT_BOTTOM_Y_PX - COUNTER_TOP_FRONT_Y_PX), COLOR_COUNTER_FRONT)
	draw_rect(Rect2(190.0, COUNTER_FRONT_BOTTOM_Y_PX - 6.0, 400.0, 6.0), COLOR_COUNTER_TRIM)

	# 左侧点单、右侧取餐；中间设备区避免两个交互点混淆。
	draw_rect(Rect2(212.0, 149.0, 72.0, 8.0), COLOR_ORDER)
	draw_rect(Rect2(496.0, 149.0, 72.0, 8.0), COLOR_PICKUP)
	draw_rect(Rect2(342.0, 127.0, 70.0, 19.0), COLOR_BEAM)
	draw_rect(Rect2(351.0, 132.0, 52.0, 9.0), Color("#7b817c"))
	for panel_x: float in [204.0, 300.0, 414.0, 510.0]:
		draw_rect(Rect2(panel_x, 166.0, 66.0, 18.0), COLOR_COUNTER_TRIM, false, 2.0)


func _draw_seating() -> void:
	_draw_small_table(Rect2(712.0, 122.0, 126.0, 13.0))
	_draw_side_chair(Vector2(688.0, 140.0))
	_draw_side_chair(Vector2(862.0, 140.0))

	_draw_small_table(Rect2(922.0, 122.0, 126.0, 13.0))
	_draw_side_chair(Vector2(898.0, 140.0))
	_draw_side_chair(Vector2(1072.0, 140.0))

	# 两个后侧座位面向观众，左右端座位使用侧面；前侧留空作为主通道。
	# 后侧凳子与坐姿角色先绘制，让桌面自然遮挡下半身。
	for back_seat_x: float in [825.0, 985.0]:
		_draw_stool(Vector2(back_seat_x, 202.0))
		_draw_front_seated_actor(Vector2(back_seat_x, 208.0))
	_draw_table(Rect2(710.0, 198.0, 390.0, 15.0), 17.0)
	_draw_stool(Vector2(686.0, 229.0))
	_draw_side_seated_actor(Vector2(686.0, 220.0), true)
	_draw_stool(Vector2(1124.0, 229.0))
	_draw_side_seated_actor(Vector2(1124.0, 220.0), false)


func _draw_landmarks() -> void:
	# 壁炉位于最右侧，只作为次级焦点，不挤占两组靠窗桌。
	draw_rect(Rect2(1162.0, 64.0, 76.0, 101.0), COLOR_BEAM)
	draw_rect(Rect2(1172.0, 91.0, 56.0, 57.0), Color("#42302c"))
	draw_rect(Rect2(1184.0, 109.0, 32.0, 29.0), Color("#6d3325"))
	draw_circle(Vector2(1200.0, 126.0), 10.0, COLOR_FIRE)

	_draw_plant(Vector2(1127.0, 164.0))
	_draw_plant(Vector2(650.0, 123.0))
	draw_rect(Rect2(105.0, 72.0, 7.0, 32.0), COLOR_BEAM)
	draw_circle(Vector2(108.5, 69.0), 7.0, COLOR_BEAM)


func _draw_scale_references() -> void:
	# 两名店员验证工作区宽度；柜台会自然遮挡其下半身。
	_draw_actor(Vector2(270.0, 145.0), COLOR_BARISTA_BODY)
	_draw_actor(Vector2(465.0, 145.0), COLOR_BARISTA_BODY)
	# 玩家比例尺放在主通道中，确认桌椅与柜台没有使用插画式大比例。
	_draw_actor(Vector2(640.0, 222.0), COLOR_ACTOR_BODY)


func _draw_routes() -> void:
	# 半透明路线仅供灰盒判断；正式场景不会显示。
	draw_rect(Rect2(112.0, 200.0, 560.0, 24.0), COLOR_ROUTE)
	draw_rect(Rect2(620.0, 154.0, 26.0, 70.0), COLOR_ROUTE)
	draw_rect(Rect2(646.0, 164.0, 466.0, 24.0), COLOR_ROUTE)


func _draw_actor(feet_position: Vector2, body_color: Color) -> void:
	draw_rect(Rect2(feet_position - Vector2(ACTOR_SIZE_PX.x * 0.36, 31.0), Vector2(ACTOR_SIZE_PX.x * 0.72, 31.0)), body_color)
	draw_circle(feet_position + Vector2(0.0, -40.0), 9.0, COLOR_SKIN)
	draw_rect(Rect2(feet_position + Vector2(-9.0, -50.0), Vector2(18.0, 6.0)), COLOR_BEAM)
	draw_rect(Rect2(feet_position + Vector2(-10.0, 0.0), Vector2(8.0, 4.0)), COLOR_COUNTER_TRIM)
	draw_rect(Rect2(feet_position + Vector2(2.0, 0.0), Vector2(8.0, 4.0)), COLOR_COUNTER_TRIM)


func _draw_window(window_rect: Rect2) -> void:
	draw_rect(window_rect.grow(5.0), COLOR_BEAM)
	draw_rect(window_rect, COLOR_WINDOW_SKY)
	draw_rect(Rect2(window_rect.position.x, window_rect.position.y + 35.0, window_rect.size.x, 25.0), COLOR_WINDOW)
	draw_line(Vector2(window_rect.get_center().x, window_rect.position.y), Vector2(window_rect.get_center().x, window_rect.end.y), COLOR_BEAM, 4.0)
	draw_line(Vector2(window_rect.position.x, window_rect.get_center().y), Vector2(window_rect.end.x, window_rect.get_center().y), COLOR_BEAM, 4.0)


func _draw_small_table(top_rect: Rect2) -> void:
	_draw_table(top_rect, 12.0)


func _draw_table(top_rect: Rect2, front_height_px: float) -> void:
	draw_rect(top_rect, COLOR_TABLE_TOP)
	draw_rect(Rect2(top_rect.position.x, top_rect.end.y, top_rect.size.x, front_height_px), COLOR_TABLE_FRONT)
	draw_rect(Rect2(top_rect.position.x + 9.0, top_rect.end.y + front_height_px, 6.0, 14.0), COLOR_COUNTER_TRIM)
	draw_rect(Rect2(top_rect.end.x - 15.0, top_rect.end.y + front_height_px, 6.0, 14.0), COLOR_COUNTER_TRIM)


func _draw_side_chair(chair_position: Vector2) -> void:
	draw_rect(Rect2(chair_position - Vector2(9.0, 14.0), Vector2(18.0, 25.0)), COLOR_CHAIR)
	draw_rect(Rect2(chair_position - Vector2(10.0, -11.0), Vector2(20.0, 7.0)), COLOR_BEAM)


func _draw_stool(stool_position: Vector2) -> void:
	draw_rect(Rect2(stool_position - Vector2(13.0, 8.0), Vector2(26.0, 8.0)), COLOR_CHAIR)
	draw_line(stool_position + Vector2(-8.0, 0.0), stool_position + Vector2(-10.0, 16.0), COLOR_COUNTER_TRIM, 3.0)
	draw_line(stool_position + Vector2(8.0, 0.0), stool_position + Vector2(10.0, 16.0), COLOR_COUNTER_TRIM, 3.0)


func _draw_front_seated_actor(seat_position: Vector2) -> void:
	# 正面坐姿只用于验证面向与遮挡，正式角色仍需独立动画资源。
	draw_rect(Rect2(seat_position - Vector2(10.0, 24.0), Vector2(20.0, 27.0)), COLOR_ACTOR_BODY)
	draw_circle(seat_position + Vector2(0.0, -32.0), 8.0, COLOR_SKIN)
	draw_rect(Rect2(seat_position + Vector2(-8.0, -41.0), Vector2(16.0, 5.0)), COLOR_BEAM)
	draw_circle(seat_position + Vector2(-3.0, -32.0), 1.0, COLOR_BEAM)
	draw_circle(seat_position + Vector2(3.0, -32.0), 1.0, COLOR_BEAM)


func _draw_side_seated_actor(seat_position: Vector2, face_right: bool) -> void:
	var facing_sign := 1.0 if face_right else -1.0
	draw_rect(Rect2(seat_position - Vector2(9.0, 23.0), Vector2(18.0, 27.0)), COLOR_ACTOR_BODY)
	draw_circle(seat_position + Vector2(0.0, -31.0), 8.0, COLOR_SKIN)
	draw_rect(Rect2(seat_position + Vector2(-8.0, -40.0), Vector2(16.0, 5.0)), COLOR_BEAM)
	draw_circle(seat_position + Vector2(facing_sign * 4.0, -32.0), 1.0, COLOR_BEAM)
	draw_line(seat_position + Vector2(facing_sign * 8.0, -30.0), seat_position + Vector2(facing_sign * 11.0, -29.0), COLOR_SKIN, 2.0)


func _draw_plant(base_position: Vector2) -> void:
	draw_circle(base_position - Vector2(0.0, 13.0), 11.0, COLOR_PLANT)
	draw_rect(Rect2(base_position - Vector2(8.0, 4.0), Vector2(16.0, 12.0)), COLOR_COUNTER_TRIM)
