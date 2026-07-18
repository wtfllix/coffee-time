extends SceneTree

## 音乐播放器面板的无窗口自动化测试。
##
## 运行：godot4 --headless --path . --script tests/test_music_panel.gd
## 预期：输出 [PASS]，进程退出码为 0。

const MusicPanelScript := preload("res://scripts/ui/music_panel.gd")

var failure_count: int = 0
var selected_channel_id: StringName = &""
var requested_volume: float = -1.0
var play_request_count: int = 0
var stop_request_count: int = 0
var panel: Control


func _init() -> void:
	panel = MusicPanelScript.new()
	root.add_child(panel)
	panel.channel_selected.connect(_on_channel_selected)
	panel.volume_changed.connect(_on_volume_changed)
	panel.play_requested.connect(_on_play_requested)
	panel.stop_requested.connect(_on_stop_requested)
	call_deferred("_run_checks")


func _run_checks() -> void:
	panel.configure(&"soft_jazz", 0.35, false, false)
	_check(not panel.expanded_menu.visible, "music controls start collapsed")
	panel.menu_button.pressed.emit()
	_check(panel.expanded_menu.visible, "music button expands the controls")
	_check(panel.menu_button.text == "收起音乐", "expanded button explains how to close")
	var selected_index: int = panel.channel_selector.selected
	_check(
		StringName(panel.channel_selector.get_item_metadata(selected_index)) == &"soft_jazz",
		"configure restores the selected channel"
	)
	_check(is_equal_approx(panel.volume_slider.value, 35.0), "configure restores volume percent")
	_check(panel.playback_button.text == "播放", "stopped state displays play")
	_check(panel.availability_label.text == "尚无已批准曲目", "missing tracks are explained")

	panel.channel_selector.select(2)
	panel.channel_selector.item_selected.emit(2)
	_check(selected_channel_id == &"warm_acoustic", "channel selection emits stable ID")
	panel.volume_slider.value = 60.0
	_check(is_equal_approx(requested_volume, 0.6), "slider emits normalized volume")
	panel.playback_button.pressed.emit()
	_check(play_request_count == 1, "stopped button requests playback")

	panel.set_playing(true)
	panel.playback_button.pressed.emit()
	_check(stop_request_count == 1, "playing button requests stop")
	panel.menu_button.pressed.emit()
	_check(not panel.expanded_menu.visible, "music button collapses the controls")

	if failure_count > 0:
		quit(1)
		return
	print("[PASS] MusicPanel exposes channel, playback, volume, and availability controls.")
	quit(0)


func _on_channel_selected(channel_id: StringName) -> void:
	selected_channel_id = channel_id


func _on_volume_changed(volume: float) -> void:
	requested_volume = volume


func _on_play_requested() -> void:
	play_request_count += 1


func _on_stop_requested() -> void:
	stop_request_count += 1


func _check(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("[FAIL] %s" % description)
	failure_count += 1
