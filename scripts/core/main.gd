extends Node

## 主场景装配器。
##
## 职责：
## - 将窗口停靠到当前显示器任务栏上方。
## - 创建色块咖啡店与原型工具栏。
## - 转发工具栏产生的窗口生命周期操作。
##
## 依赖：
## - res://scripts/cafe/cafe_prototype.gd
## - res://scripts/ui/prototype_toolbar.gd
## - res://scripts/orders/order_controller.gd
## - res://scripts/ui/order_panel.gd

const CafePrototype := preload("res://scripts/cafe/cafe_prototype.gd")
const PrototypeToolbar := preload("res://scripts/ui/prototype_toolbar.gd")
const OrderControllerScript := preload("res://scripts/orders/order_controller.gd")
const OrderPanelScript := preload("res://scripts/ui/order_panel.gd")
const CoffeeDrink: DrinkDefinition = preload("res://data/drinks/coffee.tres")
const TeaDrink: DrinkDefinition = preload("res://data/drinks/tea.tres")

## 默认窗口占当前显示器可用高度的比例。
## 单位：0.0–1.0 的屏幕比例。
const DEFAULT_HEIGHT_RATIO: float = 0.25

var cafe: Control
var toolbar: Control
var order_controller: OrderController
var order_panel: OrderPanel
var running_embedded: bool = false


func _ready() -> void:
	_configure_desktop_window()
	_build_prototype()


## 根据当前显示器的“可用矩形”设置窗口，因此不会覆盖 Windows 任务栏。
func _configure_desktop_window() -> void:
	var window := get_window()
	running_embedded = window.is_embedded()
	if running_embedded:
		# Godot 编辑器的嵌入预览不支持移动、置顶和禁用缩放。
		# 跳过这些原生窗口操作，避免初学者看到与项目无关的报错。
		return

	var screen_index := window.current_screen
	var usable_rect := DisplayServer.screen_get_usable_rect(screen_index)
	var target_height := maxi(180, roundi(usable_rect.size.y * DEFAULT_HEIGHT_RATIO))
	var target_size := Vector2i(usable_rect.size.x, target_height)
	var target_position := Vector2i(
		usable_rect.position.x,
		usable_rect.end.y - target_height
	)

	window.borderless = true
	window.unresizable = true
	window.always_on_top = true
	window.size = target_size
	window.position = target_position


## 创建运行时节点，减少原型阶段场景文件里的重复配置。
func _build_prototype() -> void:
	order_controller = OrderControllerScript.new()
	order_controller.name = "OrderController"
	add_child(order_controller)

	cafe = CafePrototype.new()
	cafe.name = "CafePrototype"
	add_child(cafe)
	cafe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	toolbar = PrototypeToolbar.new()
	toolbar.name = "PrototypeToolbar"
	add_child(toolbar)
	toolbar.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	toolbar.offset_left = -520.0
	toolbar.offset_top = 12.0
	toolbar.offset_right = -12.0
	toolbar.offset_bottom = 56.0

	order_panel = OrderPanelScript.new()
	order_panel.name = "OrderPanel"
	add_child(order_panel)
	order_panel.set_anchors_preset(Control.PRESET_CENTER)
	order_panel.offset_left = -150.0
	order_panel.offset_top = -72.0
	order_panel.offset_right = 150.0
	order_panel.offset_bottom = 88.0
	var available_drinks: Array[DrinkDefinition] = [CoffeeDrink, TeaDrink]
	order_panel.configure(available_drinks)

	cafe.status_changed.connect(toolbar.set_status)
	cafe.interaction_requested.connect(_on_cafe_interaction_requested)
	toolbar.always_on_top_changed.connect(_on_always_on_top_changed)
	toolbar.quit_requested.connect(_on_quit_requested)
	order_controller.state_changed.connect(_on_order_state_changed)
	order_panel.drink_selected.connect(_on_drink_selected)
	order_panel.cancelled.connect(_on_order_cancelled)
	cafe.set_order_state(order_controller.get_state_name())

	if running_embedded:
		toolbar.set_topmost_available(false)
		toolbar.set_status(tr("当前为编辑器嵌入预览；请切换为浮动窗口测试桌面停靠"))


## 接收方：res://scripts/ui/prototype_toolbar.gd
## enabled 为 true 时，咖啡店覆盖普通窗口；false 时允许其他应用盖住它。
func _on_always_on_top_changed(enabled: bool) -> void:
	if running_embedded:
		toolbar.set_status(tr("嵌入预览不支持置顶；请使用浮动窗口运行"))
		return
	get_window().always_on_top = enabled
	toolbar.set_status(tr("已开启置顶") if enabled else tr("已取消置顶"))


## 安全退出应用。首版不需要强制角色走到店门。
func _on_quit_requested() -> void:
	get_tree().quit()


## 接收方：res://scripts/cafe/cafe_prototype.gd
## kind 表示抵达后的情境动作；index 只在座位交互时使用。
func _on_cafe_interaction_requested(kind: StringName, index: int) -> void:
	match kind:
		&"order":
			if order_controller.get_state_name() == &"idle":
				order_panel.open_menu()
				toolbar.set_status(tr("请选择一杯饮品"))
			else:
				toolbar.set_status(order_controller.get_hint())
		&"pickup":
			if not order_controller.pick_up():
				toolbar.set_status(order_controller.get_hint())
		&"seat":
			if not cafe.confirm_seated(index):
				toolbar.set_status(tr("这个座位暂时不可用，请选择绿色空座"))
				return
			if order_controller.get_state_name() == &"carried":
				order_controller.start_drinking()
			else:
				toolbar.set_status(tr("你安静地坐了下来"))
		&"dismiss_empty":
			if not order_controller.dismiss_empty_cup():
				toolbar.set_status(order_controller.get_hint())


## 接收方：res://scripts/ui/order_panel.gd
func _on_drink_selected(drink: DrinkDefinition) -> void:
	if order_controller.place_order(drink):
		order_panel.close_menu()
	else:
		toolbar.set_status(order_controller.get_hint())


func _on_order_cancelled() -> void:
	order_panel.close_menu()
	toolbar.set_status(tr("你决定暂时不点单"))


## 接收方：res://scripts/orders/order_controller.gd
func _on_order_state_changed(state_name: StringName, message: String) -> void:
	cafe.set_order_state(state_name)
	toolbar.set_status(message)
