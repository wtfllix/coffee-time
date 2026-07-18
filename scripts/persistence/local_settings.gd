class_name LocalSettings
extends RefCounted

## 本地设置读写器。
##
## 职责：使用 ConfigFile 保存音乐频道和线性音量，不保存播放状态。
## 输入：MusicController 提供的频道 ID 与 0.0–1.0 音量。
## 输出：经过默认值和范围校验的设置 Dictionary。
## 依赖：Godot 的 user:// 可写目录；默认文件为 user://settings.cfg。

const DEFAULT_PATH := "user://settings.cfg"
const MUSIC_SECTION := "music"
const CHANNEL_KEY := "channel_id"
const VOLUME_KEY := "volume"

var settings_path: String


func _init(custom_path: String = DEFAULT_PATH) -> void:
	settings_path = custom_path


## 读取音乐设置。文件缺失或字段无效时使用传入的安全默认值。
func load_music_settings(
	default_channel_id: StringName,
	default_volume: float,
	allowed_channel_ids: Array[StringName]
) -> Dictionary:
	var result := {
		"channel_id": default_channel_id,
		"volume": clampf(default_volume, 0.0, 1.0),
	}
	var config := ConfigFile.new()
	if config.load(settings_path) != OK:
		return result

	var stored_channel := StringName(
		config.get_value(MUSIC_SECTION, CHANNEL_KEY, String(default_channel_id))
	)
	if stored_channel in allowed_channel_ids:
		result["channel_id"] = stored_channel

	var stored_volume := float(config.get_value(MUSIC_SECTION, VOLUME_KEY, default_volume))
	result["volume"] = clampf(stored_volume, 0.0, 1.0)
	return result


## 保存频道和音量并返回 Godot Error；播放状态刻意不保存，每次启动由用户主动播放。
func save_music_settings(channel_id: StringName, normalized_volume: float) -> Error:
	var config := ConfigFile.new()
	config.set_value(MUSIC_SECTION, CHANNEL_KEY, String(channel_id))
	config.set_value(MUSIC_SECTION, VOLUME_KEY, clampf(normalized_volume, 0.0, 1.0))
	return config.save(settings_path)
