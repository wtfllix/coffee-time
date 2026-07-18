extends SceneTree

## 音乐控制器与本地设置的无窗口自动化测试。
##
## 运行：godot4 --headless --path . --script tests/test_music_controller.gd
## 预期：输出 [PASS]，进程退出码为 0。

const MusicControllerScript := preload("res://scripts/audio/music_controller.gd")
const LocalSettingsScript := preload("res://scripts/persistence/local_settings.gd")
const TEST_SETTINGS_PATH := "user://test_music_settings.cfg"

var failure_count: int = 0


func _init() -> void:
	var controller := MusicControllerScript.new()
	root.add_child(controller)

	_check(controller.current_channel_id == &"quiet_piano", "default channel is quiet piano")
	_check(not controller.request_play(), "playback stays stopped without approved tracks")
	_check(controller.select_channel(&"soft_jazz"), "known channel can be selected")
	_check(not controller.select_channel(&"unknown"), "unknown channel is rejected")
	controller.set_volume(1.5)
	_check(is_equal_approx(controller.volume, 1.0), "volume is clamped to one")

	var test_streams: Array[AudioStream] = [AudioStreamWAV.new()]
	_check(controller.configure_channel(&"soft_jazz", test_streams), "known channel accepts a track pool")
	_check(controller.has_playable_tracks(), "configured channel reports playable tracks")

	var settings := LocalSettingsScript.new(TEST_SETTINGS_PATH)
	_check(settings.save_music_settings(&"soft_jazz", 0.35) == OK, "music settings save successfully")
	var loaded: Dictionary = settings.load_music_settings(
		MusicControllerScript.DEFAULT_CHANNEL_ID,
		MusicControllerScript.DEFAULT_VOLUME,
		MusicControllerScript.CHANNEL_IDS
	)
	_check(loaded["channel_id"] == &"soft_jazz", "saved channel is restored")
	_check(is_equal_approx(loaded["volume"], 0.35), "saved volume is restored")

	var invalid_settings := LocalSettingsScript.new(TEST_SETTINGS_PATH)
	_check(invalid_settings.save_music_settings(&"unknown", -2.0) == OK, "invalid values can be written safely")
	var validated: Dictionary = invalid_settings.load_music_settings(
		MusicControllerScript.DEFAULT_CHANNEL_ID,
		MusicControllerScript.DEFAULT_VOLUME,
		MusicControllerScript.CHANNEL_IDS
	)
	_check(validated["channel_id"] == MusicControllerScript.DEFAULT_CHANNEL_ID, "unknown stored channel uses default")
	_check(is_equal_approx(validated["volume"], 0.0), "stored volume is clamped")

	if failure_count > 0:
		quit(1)
		return
	print("[PASS] MusicController and LocalSettings preserve validated playback preferences.")
	quit(0)


func _check(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("[FAIL] %s" % description)
	failure_count += 1
