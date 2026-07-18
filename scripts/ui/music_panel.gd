class_name MusicPanel
extends Control

## 原型音乐播放器面板。
##
## 职责：用单个按钮展开或收起频道、播放、音量和曲目状态，不直接操作音频或文件。
## 输入：主场景同步的频道、音量、播放状态和当前频道是否有曲目。
## 输出：用户操作信号，由 res://scripts/core/main.gd 转发给 MusicController。
## 依赖：res://scripts/audio/music_controller.gd 提供稳定频道 ID。

## 发送方：本面板；接收方：res://scripts/core/main.gd。
signal channel_selected(channel_id: StringName)

## 发送方：本面板；接收方：res://scripts/core/main.gd。
signal play_requested

## 发送方：本面板；接收方：res://scripts/core/main.gd。
signal stop_requested

## 发送方：本面板；接收方：res://scripts/core/main.gd。
signal volume_changed(volume: float)

const CHANNEL_LABELS := {
	&"quiet_piano": "安静钢琴",
	&"soft_jazz": "柔和爵士",
	&"warm_acoustic": "温暖木吉他",
}
const MusicControllerScript := preload("res://scripts/audio/music_controller.gd")
const VOLUME_PERCENT_SCALE: float = 100.0
const MENU_BUTTON_WIDTH_PIXELS: float = 84.0
const MENU_BUTTON_HEIGHT_PIXELS: float = 40.0
const EXPANDED_MENU_WIDTH_PIXELS: float = 598.0
const EXPANDED_MENU_HEIGHT_PIXELS: float = 44.0
const MENU_VERTICAL_GAP_PIXELS: float = 8.0

var menu_button: Button
var expanded_menu: PanelContainer
var channel_selector: OptionButton
var playback_button: Button
var volume_slider: HSlider
var availability_label: Label
var is_playing: bool = false
var suppress_user_signals: bool = false


func _ready() -> void:
	_build_controls()


## 同步完整播放器显示；初始化和设置恢复时不会反向发送用户操作信号。
func configure(
	channel_id: StringName,
	normalized_volume: float,
	playing: bool,
	has_tracks: bool
) -> void:
	suppress_user_signals = true
	_select_channel_item(channel_id)
	volume_slider.value = clampf(normalized_volume, 0.0, 1.0) * VOLUME_PERCENT_SCALE
	suppress_user_signals = false
	set_playing(playing)
	set_track_availability(has_tracks)


## 更新播放按钮文字。
func set_playing(playing: bool) -> void:
	is_playing = playing
	if is_instance_valid(playback_button):
		playback_button.text = tr("停止") if is_playing else tr("播放")


## 更新当前频道的曲目提示。无曲目时仍允许点击播放，以显示清晰反馈。
func set_track_availability(has_tracks: bool) -> void:
	if not is_instance_valid(availability_label):
		return
	availability_label.text = tr("可以播放") if has_tracks else tr("尚无已批准曲目")


func _build_controls() -> void:
	# 根控件覆盖一块布局区域但不拦截咖啡店点击，只有按钮和展开菜单接收鼠标。
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	menu_button = Button.new()
	menu_button.text = tr("音乐")
	menu_button.tooltip_text = tr("展开音乐播放器")
	menu_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	menu_button.offset_left = -MENU_BUTTON_WIDTH_PIXELS
	menu_button.offset_top = -MENU_BUTTON_HEIGHT_PIXELS
	menu_button.offset_right = 0.0
	menu_button.offset_bottom = 0.0
	menu_button.pressed.connect(_on_menu_button_pressed)
	add_child(menu_button)

	expanded_menu = PanelContainer.new()
	expanded_menu.visible = false
	expanded_menu.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	expanded_menu.offset_left = -EXPANDED_MENU_WIDTH_PIXELS
	expanded_menu.offset_top = -MENU_BUTTON_HEIGHT_PIXELS - MENU_VERTICAL_GAP_PIXELS - EXPANDED_MENU_HEIGHT_PIXELS
	expanded_menu.offset_right = 0.0
	expanded_menu.offset_bottom = -MENU_BUTTON_HEIGHT_PIXELS - MENU_VERTICAL_GAP_PIXELS
	add_child(expanded_menu)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	expanded_menu.add_child(row)

	channel_selector = OptionButton.new()
	channel_selector.tooltip_text = tr("选择氛围音乐频道")
	for channel_id: StringName in MusicControllerScript.CHANNEL_IDS:
		channel_selector.add_item(tr(CHANNEL_LABELS[channel_id]))
		channel_selector.set_item_metadata(channel_selector.item_count - 1, channel_id)
	channel_selector.item_selected.connect(_on_channel_item_selected)
	row.add_child(channel_selector)

	playback_button = Button.new()
	playback_button.text = tr("播放")
	playback_button.tooltip_text = tr("音乐每次启动后需要主动播放")
	playback_button.pressed.connect(_on_playback_pressed)
	row.add_child(playback_button)

	var volume_label := Label.new()
	volume_label.text = tr("音量")
	volume_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(volume_label)

	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = VOLUME_PERCENT_SCALE
	volume_slider.step = 1.0
	volume_slider.custom_minimum_size.x = 96.0
	volume_slider.tooltip_text = tr("音乐音量")
	volume_slider.value_changed.connect(_on_volume_value_changed)
	row.add_child(volume_slider)

	availability_label = Label.new()
	availability_label.text = tr("尚无已批准曲目")
	availability_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(availability_label)


func _on_menu_button_pressed() -> void:
	expanded_menu.visible = not expanded_menu.visible
	menu_button.text = tr("收起音乐") if expanded_menu.visible else tr("音乐")
	menu_button.tooltip_text = (
		tr("收起音乐播放器") if expanded_menu.visible else tr("展开音乐播放器")
	)


func _select_channel_item(channel_id: StringName) -> void:
	for item_index in channel_selector.item_count:
		if StringName(channel_selector.get_item_metadata(item_index)) == channel_id:
			channel_selector.select(item_index)
			return


func _on_channel_item_selected(item_index: int) -> void:
	if suppress_user_signals:
		return
	var channel_id := StringName(channel_selector.get_item_metadata(item_index))
	channel_selected.emit(channel_id)


func _on_playback_pressed() -> void:
	if is_playing:
		stop_requested.emit()
	else:
		play_requested.emit()


func _on_volume_value_changed(percent: float) -> void:
	if suppress_user_signals:
		return
	volume_changed.emit(percent / VOLUME_PERCENT_SCALE)
