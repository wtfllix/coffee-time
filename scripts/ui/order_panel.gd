class_name OrderPanel
extends PanelContainer

## 原型点单面板。
##
## 输入：由 res://scripts/core/main.gd 提供饮品资源并控制显示。
## 输出：drink_selected 或 cancelled。

## 发送方：本面板；接收方：res://scripts/core/main.gd。
signal drink_selected(drink: DrinkDefinition)

## 发送方：本面板；接收方：res://scripts/core/main.gd。
signal cancelled

var drinks: Array[DrinkDefinition] = []
var button_column: VBoxContainer


func _ready() -> void:
	visible = false
	_build_controls()


## 设置点单选项。可以在运行时替换资源，无需修改 UI 脚本。
func configure(available_drinks: Array[DrinkDefinition]) -> void:
	drinks = available_drinks
	_refresh_drink_buttons()


## 打开菜单并将键盘焦点交给第一个饮品按钮。
func open_menu() -> void:
	visible = true
	if button_column.get_child_count() > 0:
		var first_button := button_column.get_child(0) as Button
		first_button.grab_focus()


func close_menu() -> void:
	visible = false


func _build_controls() -> void:
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)

	var title := Label.new()
	title.text = tr("请选择一杯饮品")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)

	button_column = VBoxContainer.new()
	button_column.add_theme_constant_override("separation", 6)
	content.add_child(button_column)

	var cancel_button := Button.new()
	cancel_button.text = tr("暂时不点单")
	cancel_button.pressed.connect(_on_cancel_pressed)
	content.add_child(cancel_button)


func _refresh_drink_buttons() -> void:
	if not is_instance_valid(button_column):
		return
	for child in button_column.get_children():
		child.queue_free()

	for drink in drinks:
		var drink_button := Button.new()
		drink_button.text = tr("%s（制作 %.0f 秒）") % [tr(drink.display_name), drink.preparation_seconds]
		drink_button.pressed.connect(_on_drink_pressed.bind(drink))
		button_column.add_child(drink_button)


func _on_drink_pressed(drink: DrinkDefinition) -> void:
	drink_selected.emit(drink)


func _on_cancel_pressed() -> void:
	cancelled.emit()

