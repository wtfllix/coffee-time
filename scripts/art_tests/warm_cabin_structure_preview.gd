extends Control

## 温暖木屋结构层候选素材预览。
##
## 输入：六张从 CON-006 候选图拆出的结构 PNG；以 1280×270 像素为设计基准。
## 输出：重复铺设的墙地、墙脚、门、窗框与立柱，用于暴露接缝和比例问题。
## 依赖：res://assets/candidates/warm_cabin/structure_v1/；仅供
## res://scenes/art_tests/warm_cabin_structure_preview.tscn 使用。
##
## 素材仍为 Candidate。该场景故意重复铺设纹理，不能因为单件好看而掩盖
## 不连续边缘；确认前不得接入 res://scenes/main.tscn。

const DESIGN_WIDTH_PX: float = 1280.0
const DESIGN_HEIGHT_PX: float = 270.0
const WALL_HEIGHT_PX: float = 104.0

const WallPanel: Texture2D = preload("res://assets/candidates/warm_cabin/structure_v1/wall_panel.png")
const FloorPanel: Texture2D = preload("res://assets/candidates/warm_cabin/structure_v1/floor_panel.png")
const Baseboard: Texture2D = preload("res://assets/candidates/warm_cabin/structure_v1/baseboard.png")
const Post: Texture2D = preload("res://assets/candidates/warm_cabin/structure_v1/post.png")
const Door: Texture2D = preload("res://assets/candidates/warm_cabin/structure_v1/door.png")
const WindowFrame: Texture2D = preload("res://assets/candidates/warm_cabin/structure_v1/window_frame.png")

const COLOR_VOID := Color("#151218")
const COLOR_DEFAULT_SKY := Color("#99d0dc")
const COLOR_DEFAULT_LAND := Color("#587d5a")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var canvas_scale := Vector2(size.x / DESIGN_WIDTH_PX, size.y / DESIGN_HEIGHT_PX)
	draw_set_transform(Vector2.ZERO, 0.0, canvas_scale)
	draw_rect(Rect2(0.0, 0.0, DESIGN_WIDTH_PX, DESIGN_HEIGHT_PX), COLOR_VOID)
	_draw_repeated_shell()
	_draw_weather_inserts()
	_draw_architecture()


func _draw_repeated_shell() -> void:
	# 直接重复而不拉伸，接缝问题会在预览中原样出现。
	var wall_size := WallPanel.get_size()
	for wall_x in range(0, int(DESIGN_WIDTH_PX), int(wall_size.x)):
		draw_texture(WallPanel, Vector2(float(wall_x), 0.0))

	var floor_size := FloorPanel.get_size()
	for floor_y in range(int(WALL_HEIGHT_PX), int(DESIGN_HEIGHT_PX), int(floor_size.y)):
		for floor_x in range(0, int(DESIGN_WIDTH_PX), int(floor_size.x)):
			draw_texture(FloorPanel, Vector2(float(floor_x), float(floor_y)))

	var baseboard_width := int(Baseboard.get_width())
	for trim_x in range(0, int(DESIGN_WIDTH_PX), baseboard_width):
		draw_texture(Baseboard, Vector2(float(trim_x), WALL_HEIGHT_PX - 18.0))


func _draw_weather_inserts() -> void:
	# 外景位于窗框后方，未来可替换为当地天气纹理而不重画墙体。
	for window_x: float in [720.0, 930.0]:
		draw_rect(Rect2(window_x + 10.0, 12.0, 60.0, 78.0), COLOR_DEFAULT_SKY)
		draw_rect(Rect2(window_x + 10.0, 64.0, 60.0, 26.0), COLOR_DEFAULT_LAND)


func _draw_architecture() -> void:
	draw_texture(Door, Vector2(32.0, 0.0))
	draw_texture(Post, Vector2(170.0, 0.0))
	draw_texture(Post, Vector2(620.0, 0.0))
	draw_texture(WindowFrame, Vector2(720.0, 0.0))
	draw_texture(WindowFrame, Vector2(930.0, 0.0))
