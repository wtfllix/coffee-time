class_name MusicController
extends Node

## 氛围音乐播放状态控制器。
##
## 职责：管理频道、音量、播放意图和频道曲目池，并将实际播放交给 AudioStreamPlayer。
## 输入：主场景配置的已批准 AudioStream、频道选择和播放操作。
## 输出：频道、音量与播放状态信号，供界面和本地设置同步。
## 依赖：只有在 res://ASSETS.md 标记为 Approved 的音乐才可传入 configure_channel()。

## 发送方：本控制器；接收方：主场景与音乐界面。
signal channel_changed(channel_id: StringName)

## 发送方：本控制器；接收方：主场景与音乐界面。
signal volume_changed(volume: float)

## 发送方：本控制器；接收方：主场景与音乐界面。
signal playback_changed(is_playing: bool)

## 首版固定频道 ID；显示名称由界面负责翻译。
const CHANNEL_IDS: Array[StringName] = [&"quiet_piano", &"soft_jazz", &"warm_acoustic"]
const DEFAULT_CHANNEL_ID: StringName = &"quiet_piano"
const DEFAULT_VOLUME: float = 0.5
const MIN_AUDIBLE_LINEAR_VOLUME: float = 0.0001

var current_channel_id: StringName = DEFAULT_CHANNEL_ID
var volume: float = DEFAULT_VOLUME
var playback_requested: bool = false
var tracks_by_channel: Dictionary = {}
var audio_player: AudioStreamPlayer
var random_number_generator := RandomNumberGenerator.new()


func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.name = "AmbientMusicPlayer"
	audio_player.finished.connect(_on_track_finished)
	add_child(audio_player)
	random_number_generator.randomize()
	_apply_volume()


## 替换一个频道的已批准曲目池。空数组可用于尚无授权音乐的原型阶段。
func configure_channel(channel_id: StringName, tracks: Array[AudioStream]) -> bool:
	if channel_id not in CHANNEL_IDS:
		return false
	tracks_by_channel[channel_id] = tracks.duplicate()
	return true


## 切换频道。若正在播放，会从新频道随机曲目的开头继续。
func select_channel(channel_id: StringName) -> bool:
	if channel_id not in CHANNEL_IDS:
		return false
	if current_channel_id == channel_id:
		return true
	current_channel_id = channel_id
	channel_changed.emit(current_channel_id)
	if playback_requested:
		_play_random_track()
	return true


## 设置线性音量，范围为 0.0–1.0；0.0 表示静音。
func set_volume(normalized_volume: float) -> void:
	var next_volume := clampf(normalized_volume, 0.0, 1.0)
	if is_equal_approx(volume, next_volume):
		return
	volume = next_volume
	_apply_volume()
	volume_changed.emit(volume)


## 用户主动请求播放。频道无已批准曲目时返回 false，且保持停止状态。
func request_play() -> bool:
	if not _has_current_channel_tracks():
		return false
	playback_requested = true
	_play_random_track()
	playback_changed.emit(true)
	return true


## 停止音乐；下次播放从随机曲目的开头开始。
func stop() -> void:
	if not playback_requested and (audio_player == null or not audio_player.playing):
		return
	playback_requested = false
	if audio_player != null:
		audio_player.stop()
	playback_changed.emit(false)


## 返回当前频道是否配置了至少一首已批准曲目。
func has_playable_tracks() -> bool:
	return _has_current_channel_tracks()


func _has_current_channel_tracks() -> bool:
	var tracks: Array = tracks_by_channel.get(current_channel_id, [])
	return not tracks.is_empty()


func _play_random_track() -> void:
	if audio_player == null:
		return
	var tracks: Array = tracks_by_channel.get(current_channel_id, [])
	if tracks.is_empty():
		playback_requested = false
		audio_player.stop()
		playback_changed.emit(false)
		return
	var track_index := random_number_generator.randi_range(0, tracks.size() - 1)
	audio_player.stream = tracks[track_index] as AudioStream
	audio_player.play(0.0)


func _apply_volume() -> void:
	if audio_player == null:
		return
	audio_player.volume_db = linear_to_db(maxf(volume, MIN_AUDIBLE_LINEAR_VOLUME))
	audio_player.stream_paused = volume <= 0.0


func _on_track_finished() -> void:
	if playback_requested:
		_play_random_track()
