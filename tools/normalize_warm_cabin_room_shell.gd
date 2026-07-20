extends SceneTree

## CON-023 空房间结构的确定性几何规范化工具。
##
## 输入：已确认的 CON-023 墙体源图与独立地板材质源图。
## 输出：严格匹配 640×420 灰盒四角与 122 像素墙高的结构底图。
## 依赖：Godot 4.7 Image API；不修改碰撞、家具或运行场景。

const FLOOR_SOURCE_PATH := "res://assets/candidates/warm_cabin/generate2dmap_v4/warm_cabin-floor-style-source-v3.png"
const WALL_SOURCE_PATH := "res://assets/candidates/warm_cabin/generate2dmap_v4/warm_cabin-room-shell-source-v2.png"
const OUTPUT_PATH := "res://assets/candidates/warm_cabin/generate2dmap_v4/warm_cabin-room-shell-floor-v3-640x420.png"
const OUTPUT_SIZE := Vector2i(640, 420)
const SUPERSAMPLE_SCALE: int = 2
const BACKGROUND_COLOR := Color("#151820")

# 目标坐标来自已通过 Windows 检查的 10×10 等距灰盒，单位：像素。
const TARGET_BACK := Vector2(320.0, 125.0)
const TARGET_RIGHT := Vector2(600.0, 265.0)
const TARGET_FRONT := Vector2(320.0, 405.0)
const TARGET_LEFT := Vector2(40.0, 265.0)
const TARGET_BACK_TOP := Vector2(320.0, 3.0)
const TARGET_RIGHT_TOP := Vector2(600.0, 143.0)
const TARGET_LEFT_TOP := Vector2(40.0, 143.0)

# v2 源图中的稳定采样锚点。地板前锚点取前缘内侧，避开模型生成的平切厚边。
const SOURCE_FLOOR := [
	Vector2(775.0, 289.0),
	Vector2(1478.0, 670.0),
	Vector2(775.0, 970.0),
	Vector2(71.0, 670.0),
]
const SOURCE_LEFT_WALL := [
	Vector2(775.0, 30.0),
	Vector2(71.0, 431.0),
	Vector2(71.0, 670.0),
	Vector2(775.0, 289.0),
]
const SOURCE_RIGHT_WALL := [
	Vector2(775.0, 30.0),
	Vector2(1478.0, 431.0),
	Vector2(1478.0, 670.0),
	Vector2(775.0, 289.0),
]


func _init() -> void:
	var floor_source := Image.load_from_file(ProjectSettings.globalize_path(FLOOR_SOURCE_PATH))
	if floor_source.is_empty():
		push_error("无法读取 CON-023 地板源图：%s" % FLOOR_SOURCE_PATH)
		quit(1)
		return
	var wall_source := Image.load_from_file(ProjectSettings.globalize_path(WALL_SOURCE_PATH))
	if wall_source.is_empty():
		push_error("无法读取 CON-023 墙体源图：%s" % WALL_SOURCE_PATH)
		quit(1)
		return

	var render_size := OUTPUT_SIZE * SUPERSAMPLE_SCALE
	var output := Image.create(render_size.x, render_size.y, false, Image.FORMAT_RGBA8)
	output.fill(BACKGROUND_COLOR)

	for pixel_y in range(render_size.y):
		for pixel_x in range(render_size.x):
			var target_point := Vector2(
				(float(pixel_x) + 0.5) / float(SUPERSAMPLE_SCALE),
				(float(pixel_y) + 0.5) / float(SUPERSAMPLE_SCALE)
			)
			var color := BACKGROUND_COLOR
			var floor_uv := _floor_uv(target_point)
			if _is_unit_uv(floor_uv):
				color = _sample_quad(floor_source, SOURCE_FLOOR, floor_uv)

			# 墙体继续取已确认的 v2 源图，避免地板编辑造成墙窗像素漂移。
			var left_wall_uv := _left_wall_uv(target_point)
			if _is_unit_uv(left_wall_uv):
				color = _sample_quad(wall_source, SOURCE_LEFT_WALL, left_wall_uv)
			var right_wall_uv := _right_wall_uv(target_point)
			if _is_unit_uv(right_wall_uv):
				color = _sample_quad(wall_source, SOURCE_RIGHT_WALL, right_wall_uv)
			output.set_pixel(pixel_x, pixel_y, color)

	output.resize(OUTPUT_SIZE.x, OUTPUT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	var save_error := output.save_png(ProjectSettings.globalize_path(OUTPUT_PATH))
	if save_error != OK:
		push_error("无法保存 CON-023 规范化底图：%s" % error_string(save_error))
		quit(1)
		return
	print("[PASS] CON-023 selected floor v3 normalized to 640x420 locked geometry.")
	quit()


func _floor_uv(point: Vector2) -> Vector2:
	var horizontal_ratio := (point.x - TARGET_BACK.x) / (TARGET_RIGHT.x - TARGET_BACK.x)
	var depth_ratio := (point.y - TARGET_BACK.y) / (TARGET_RIGHT.y - TARGET_BACK.y)
	return Vector2(
		(horizontal_ratio + depth_ratio) * 0.5,
		(depth_ratio - horizontal_ratio) * 0.5
	)


func _left_wall_uv(point: Vector2) -> Vector2:
	var wall_ratio := (TARGET_BACK.x - point.x) / (TARGET_BACK.x - TARGET_LEFT.x)
	var height_ratio := (
		point.y - TARGET_BACK_TOP.y - (TARGET_LEFT_TOP.y - TARGET_BACK_TOP.y) * wall_ratio
	) / (TARGET_BACK.y - TARGET_BACK_TOP.y)
	return Vector2(wall_ratio, height_ratio)


func _right_wall_uv(point: Vector2) -> Vector2:
	var wall_ratio := (point.x - TARGET_BACK.x) / (TARGET_RIGHT.x - TARGET_BACK.x)
	var height_ratio := (
		point.y - TARGET_BACK_TOP.y - (TARGET_RIGHT_TOP.y - TARGET_BACK_TOP.y) * wall_ratio
	) / (TARGET_BACK.y - TARGET_BACK_TOP.y)
	return Vector2(wall_ratio, height_ratio)


func _is_unit_uv(uv: Vector2) -> bool:
	return uv.x >= 0.0 and uv.x <= 1.0 and uv.y >= 0.0 and uv.y <= 1.0


func _sample_quad(source: Image, quad: Array, uv: Vector2) -> Color:
	var source_top: Vector2 = (quad[0] as Vector2).lerp(quad[1] as Vector2, uv.x)
	var source_bottom: Vector2 = (quad[3] as Vector2).lerp(quad[2] as Vector2, uv.x)
	return _sample_bilinear(source, source_top.lerp(source_bottom, uv.y))


func _sample_bilinear(source: Image, point: Vector2) -> Color:
	var max_x := source.get_width() - 1
	var max_y := source.get_height() - 1
	var x0 := clampi(int(floor(point.x)), 0, max_x)
	var y0 := clampi(int(floor(point.y)), 0, max_y)
	var x1 := mini(x0 + 1, max_x)
	var y1 := mini(y0 + 1, max_y)
	var ratio_x := clampf(point.x - float(x0), 0.0, 1.0)
	var ratio_y := clampf(point.y - float(y0), 0.0, 1.0)
	var top := source.get_pixel(x0, y0).lerp(source.get_pixel(x1, y0), ratio_x)
	var bottom := source.get_pixel(x0, y1).lerp(source.get_pixel(x1, y1), ratio_x)
	return top.lerp(bottom, ratio_y)
