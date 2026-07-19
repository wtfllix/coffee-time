extends Control

## 正面轴向低机位俯视灰盒。
##
## 输入：当前预览窗口尺寸；以 1280×270 像素为设计基准并等比映射到画布。
## 输出：后墙、地面、柜台、桌椅和角色比例尺的程序绘制预览。
## 依赖：DEC-013 与 CON-004；只供 res://scenes/art_tests/frontal_oblique_blockout.tscn 使用。
##
## 该脚本不实现寻路或交互。它先锁定投影、空间占比和像素资产边界，
## 避免在摄像机规范尚未验证时制作正式素材。

## 设计画布宽度，单位：像素。
const DESIGN_WIDTH_PX: float = 1280.0

## 设计画布高度，单位：像素。
const DESIGN_HEIGHT_PX: float = 270.0

## 概念摄像机向下俯角，单位：度；仅作为资产绘制规范，不驱动 3D 摄像机。
const CAMERA_PITCH_DEGREES: float = 22.5

const WALL_FLOOR_Y_PX: float = 120.0
const FLOOR_FRONT_Y_PX: float = 270.0

const COLOR_VOID := Color("#11121a")
const COLOR_WALL_DARK := Color("#2a1719")
const COLOR_WALL := Color("#5a3025")
const COLOR_WALL_LIGHT := Color("#774533")
const COLOR_FLOOR_BACK := Color("#633724")
const COLOR_FLOOR_FRONT := Color("#3b2220")
const COLOR_BEAM := Color("#241418")
const COLOR_COUNTER_TOP := Color("#a86536")
const COLOR_COUNTER_FRONT := Color("#563024")
const COLOR_COUNTER_SHADOW := Color("#2c1a1b")
const COLOR_TABLE_TOP := Color("#8d5030")
const COLOR_TABLE_FRONT := Color("#4b2a22")
const COLOR_CHAIR := Color("#344437")
const COLOR_WINDOW := Color("#203750")
const COLOR_WINDOW_LIGHT := Color("#36516c")
const COLOR_AMBER := Color("#f0ad55")
const COLOR_PLANT := Color("#3f573c")
const COLOR_ACTOR := Color("#416b66")
const COLOR_SKIN := Color("#d09a70")
const COLOR_GUIDE := Color(0.48, 0.76, 0.74, 0.26)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var canvas_scale := Vector2(size.x / DESIGN_WIDTH_PX, size.y / DESIGN_HEIGHT_PX)
	draw_set_transform(Vector2.ZERO, 0.0, canvas_scale)
	_draw_room_shell()
	_draw_counter()
	_draw_seating()
	_draw_actor_scale_reference(Vector2(690.0, 211.0))
	_draw_projection_guides()


func _draw_room_shell() -> void:
	draw_rect(Rect2(0.0, 0.0, DESIGN_WIDTH_PX, DESIGN_HEIGHT_PX), COLOR_VOID)
	draw_rect(Rect2(10.0, 8.0, 1260.0, WALL_FLOOR_Y_PX - 8.0), COLOR_WALL)
	draw_rect(Rect2(10.0, 8.0, 1260.0, 12.0), COLOR_BEAM)
	draw_rect(Rect2(10.0, WALL_FLOOR_Y_PX - 8.0, 1260.0, 8.0), COLOR_BEAM)

	# 正面轴向投影中，地面左右边保持竖直，纵深只沿屏幕上下方向展开。
	draw_colored_polygon(PackedVector2Array([
		Vector2(10.0, WALL_FLOOR_Y_PX),
		Vector2(1270.0, WALL_FLOOR_Y_PX),
		Vector2(1270.0, FLOOR_FRONT_Y_PX),
		Vector2(10.0, FLOOR_FRONT_Y_PX),
	]), COLOR_FLOOR_BACK)
	draw_colored_polygon(PackedVector2Array([
		Vector2(10.0, 194.0),
		Vector2(1270.0, 194.0),
		Vector2(1270.0, FLOOR_FRONT_Y_PX),
		Vector2(10.0, FLOOR_FRONT_Y_PX),
	]), COLOR_FLOOR_FRONT)

	# 越靠后，地板纵深分隔越紧；这是低机位俯视的主要空间提示。
	for floor_y: float in [130.0, 143.0, 159.0, 179.0, 204.0, 233.0, 264.0]:
		draw_line(Vector2(10.0, floor_y), Vector2(1270.0, floor_y), COLOR_WALL_LIGHT, 1.0)
	for floor_x in range(34, 1280, 64):
		draw_line(Vector2(float(floor_x), WALL_FLOOR_Y_PX), Vector2(float(floor_x), FLOOR_FRONT_Y_PX), Color(0.16, 0.08, 0.08, 0.35), 1.0)

	_draw_window(Rect2(720.0, 30.0, 92.0, 55.0))
	_draw_window(Rect2(834.0, 30.0, 92.0, 55.0))
	_draw_window(Rect2(948.0, 30.0, 92.0, 55.0))
	_draw_lamp(Vector2(320.0, 42.0))
	_draw_lamp(Vector2(560.0, 42.0))
	_draw_lamp(Vector2(1100.0, 42.0))

	# 左侧入口位于舞台边缘，正面可读但不制造侧向透视。
	draw_rect(Rect2(24.0, 38.0, 54.0, 82.0), COLOR_BEAM)
	draw_rect(Rect2(31.0, 45.0, 40.0, 75.0), COLOR_WALL_DARK)
	draw_rect(Rect2(38.0, 52.0, 26.0, 24.0), COLOR_WINDOW)


func _draw_counter() -> void:
	var counter_x := 110.0
	var counter_width := 560.0
	var top_back_y := 126.0
	var top_front_y := 146.0
	var front_bottom_y := 202.0

	# 顶面与正面分层是本测试最重要的俯角标尺。
	draw_rect(Rect2(counter_x, top_back_y, counter_width, top_front_y - top_back_y), COLOR_COUNTER_TOP)
	draw_rect(Rect2(counter_x, top_front_y, counter_width, front_bottom_y - top_front_y), COLOR_COUNTER_FRONT)
	draw_rect(Rect2(counter_x, front_bottom_y - 8.0, counter_width, 8.0), COLOR_COUNTER_SHADOW)
	for panel_x in range(130, 650, 104):
		draw_rect(Rect2(float(panel_x), 157.0, 78.0, 34.0), COLOR_WALL_DARK, false, 2.0)

	# 咖啡机和展示柜只用大轮廓验证遮挡高度，不表达最终细节。
	draw_rect(Rect2(180.0, 84.0, 88.0, 42.0), COLOR_BEAM)
	draw_rect(Rect2(192.0, 91.0, 64.0, 24.0), COLOR_WALL_LIGHT)
	draw_rect(Rect2(300.0, 93.0, 112.0, 33.0), Color("#3b2b29"))
	draw_rect(Rect2(312.0, 101.0, 88.0, 17.0), COLOR_AMBER)
	draw_rect(Rect2(460.0, 99.0, 54.0, 27.0), COLOR_BEAM)


func _draw_seating() -> void:
	_draw_table(Rect2(786.0, 119.0, 122.0, 20.0), 18.0)
	_draw_chair(Vector2(774.0, 143.0), false)
	_draw_chair(Vector2(920.0, 143.0), true)

	_draw_table(Rect2(1012.0, 126.0, 122.0, 20.0), 18.0)
	_draw_chair(Vector2(1000.0, 150.0), false)
	_draw_chair(Vector2(1146.0, 150.0), true)

	_draw_table(Rect2(820.0, 205.0, 310.0, 24.0), 20.0)
	for chair_x: float in [846.0, 912.0, 978.0, 1044.0, 1110.0]:
		_draw_chair(Vector2(chair_x, 246.0), false)

	# 少量植物块用于观察暗绿点缀是否能从木色中分离。
	draw_circle(Vector2(748.0, 117.0), 10.0, COLOR_PLANT)
	draw_rect(Rect2(741.0, 123.0, 14.0, 10.0), COLOR_WALL_DARK)
	draw_circle(Vector2(1185.0, 182.0), 13.0, COLOR_PLANT)
	draw_rect(Rect2(1176.0, 191.0, 18.0, 14.0), COLOR_WALL_DARK)


func _draw_table(top_rect: Rect2, front_height_px: float) -> void:
	draw_rect(top_rect, COLOR_TABLE_TOP)
	draw_rect(Rect2(top_rect.position.x, top_rect.end.y, top_rect.size.x, front_height_px), COLOR_TABLE_FRONT)
	draw_rect(Rect2(top_rect.position.x + 8.0, top_rect.end.y + front_height_px, 8.0, 15.0), COLOR_COUNTER_SHADOW)
	draw_rect(Rect2(top_rect.end.x - 16.0, top_rect.end.y + front_height_px, 8.0, 15.0), COLOR_COUNTER_SHADOW)


func _draw_chair(chair_position: Vector2, face_left: bool) -> void:
	var direction := -1.0 if face_left else 1.0
	draw_rect(Rect2(chair_position.x - 9.0, chair_position.y - 18.0, 18.0, 24.0), COLOR_CHAIR)
	draw_rect(Rect2(chair_position.x - 10.0, chair_position.y + 6.0, 20.0, 8.0), COLOR_WALL_DARK)
	draw_line(chair_position + Vector2(direction * 8.0, 14.0), chair_position + Vector2(direction * 8.0, 29.0), COLOR_COUNTER_SHADOW, 3.0)


func _draw_actor_scale_reference(feet_position: Vector2) -> void:
	# 约 32×48 像素、2.5 头身；只验证角色是否能与柜台及桌椅共享画面比例。
	draw_colored_polygon(PackedVector2Array([
		feet_position + Vector2(-11.0, -31.0),
		feet_position + Vector2(11.0, -31.0),
		feet_position + Vector2(14.0, -7.0),
		feet_position + Vector2(8.0, 0.0),
		feet_position + Vector2(-8.0, 0.0),
		feet_position + Vector2(-14.0, -7.0),
	]), COLOR_ACTOR)
	draw_circle(feet_position + Vector2(0.0, -40.0), 10.0, COLOR_SKIN)
	draw_rect(Rect2(feet_position + Vector2(-9.0, -50.0), Vector2(18.0, 7.0)), COLOR_WALL_DARK)
	draw_rect(Rect2(feet_position + Vector2(-9.0, 0.0), Vector2(7.0, 4.0)), COLOR_COUNTER_SHADOW)
	draw_rect(Rect2(feet_position + Vector2(2.0, 0.0), Vector2(7.0, 4.0)), COLOR_COUNTER_SHADOW)


func _draw_window(window_rect: Rect2) -> void:
	draw_rect(window_rect.grow(5.0), COLOR_BEAM)
	draw_rect(window_rect, COLOR_WINDOW)
	draw_rect(Rect2(window_rect.position, Vector2(window_rect.size.x, 8.0)), COLOR_WINDOW_LIGHT)
	draw_line(Vector2(window_rect.get_center().x, window_rect.position.y), Vector2(window_rect.get_center().x, window_rect.end.y), COLOR_BEAM, 4.0)


func _draw_lamp(lamp_position: Vector2) -> void:
	draw_line(lamp_position - Vector2(0.0, 30.0), lamp_position - Vector2(0.0, 8.0), COLOR_BEAM, 3.0)
	draw_circle(lamp_position, 9.0, COLOR_AMBER)
	draw_circle(lamp_position, 16.0, Color(0.94, 0.52, 0.22, 0.08))


func _draw_projection_guides() -> void:
	# 细线只用于确认正面轴向：所有深度线垂直，所有横向边水平。
	draw_line(Vector2(640.0, WALL_FLOOR_Y_PX), Vector2(640.0, FLOOR_FRONT_Y_PX), COLOR_GUIDE, 1.0)
	draw_line(Vector2(10.0, WALL_FLOOR_Y_PX), Vector2(1270.0, WALL_FLOOR_Y_PX), COLOR_GUIDE, 1.0)
