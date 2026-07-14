extends PanelContainer

## 原型顶部工具栏。
##
## 输入：玩家点击置顶复选框或退出按钮。
## 输出：always_on_top_changed 与 quit_requested 信号。
## 依赖：由 res://scripts/core/main.gd 创建并接收信号。

## 发送方：本工具栏；接收方：res://scripts/core/main.gd。
signal always_on_top_changed(enabled: bool)

## 发送方：本工具栏；接收方：res://scripts/core/main.gd。
signal quit_requested

var status_label: Label
var topmost_toggle: CheckButton


func _ready() -> void:
	_build_controls()


## 更新工具栏左侧状态文本，供场景和主窗口共同使用。
func set_status(message: String) -> void:
	if is_instance_valid(status_label):
		status_label.text = message


## 嵌入编辑器预览时禁用置顶按钮，避免触发原生窗口限制错误。
func set_topmost_available(available: bool) -> void:
	if not is_instance_valid(topmost_toggle):
		return
	topmost_toggle.disabled = not available
	topmost_toggle.tooltip_text = (
		tr("关闭后，其他窗口可以覆盖咖啡店")
		if available
		else tr("编辑器嵌入预览不支持置顶，请切换为浮动窗口")
	)


func _build_controls() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	add_child(row)

	status_label = Label.new()
	status_label.text = tr("点击咖啡店地面移动")
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(status_label)

	topmost_toggle = CheckButton.new()
	topmost_toggle.text = tr("置顶")
	topmost_toggle.button_pressed = true
	topmost_toggle.tooltip_text = tr("关闭后，其他窗口可以覆盖咖啡店")
	topmost_toggle.toggled.connect(_on_topmost_toggled)
	row.add_child(topmost_toggle)

	var quit_button := Button.new()
	quit_button.text = tr("退出")
	quit_button.tooltip_text = tr("关闭 Coffee Time")
	quit_button.pressed.connect(_on_quit_pressed)
	row.add_child(quit_button)


func _on_topmost_toggled(enabled: bool) -> void:
	always_on_top_changed.emit(enabled)


func _on_quit_pressed() -> void:
	quit_requested.emit()
