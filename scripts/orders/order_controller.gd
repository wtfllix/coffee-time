class_name OrderController
extends Node

## 单人版“一次一杯”订单状态机。
##
## 输入：点单、取餐、开始饮用和关闭空杯提示。
## 输出：state_changed，供主场景更新画面和工具栏。
## 依赖：res://scripts/orders/drink_definition.gd

## 发送方：本状态机；接收方：res://scripts/core/main.gd。
signal state_changed(state_name: StringName, status_message: String)

enum State {
	IDLE,
	PREPARING,
	READY,
	CARRIED,
	DRINKING,
	EMPTY,
}

var state: State = State.IDLE
var current_drink: DrinkDefinition
var remaining_seconds: float = 0.0


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if state != State.PREPARING and state != State.DRINKING:
		return

	remaining_seconds = maxf(0.0, remaining_seconds - delta)
	if remaining_seconds > 0.0:
		return

	if state == State.PREPARING:
		_transition_to(State.READY, tr("饮品制作完成，请前往取餐台"))
	elif state == State.DRINKING:
		_transition_to(State.EMPTY, tr("饮品喝完了，点击续杯气泡即可收起空杯"))


## 创建新订单。只有 IDLE 状态允许点单，返回值表示操作是否成功。
func place_order(drink: DrinkDefinition) -> bool:
	if state != State.IDLE or drink == null:
		return false

	current_drink = drink
	remaining_seconds = drink.preparation_seconds
	_transition_to(
		State.PREPARING,
		tr("咖啡师正在制作：%s") % tr(drink.display_name)
	)
	return true


## 从取餐台拿起饮品。制作完成前调用会返回 false。
func pick_up() -> bool:
	if state != State.READY:
		return false
	_transition_to(State.CARRIED, tr("已取到饮品，请选择座位"))
	return true


## 入座后开始计时饮用。没有持杯时调用会返回 false。
func start_drinking() -> bool:
	if state != State.CARRIED or current_drink == null:
		return false
	remaining_seconds = current_drink.consumption_seconds
	_transition_to(
		State.DRINKING,
		tr("正在慢慢饮用：%s") % tr(current_drink.display_name)
	)
	return true


## 玩家点击持续气泡后清除空杯，回到可点单状态。
func dismiss_empty_cup() -> bool:
	if state != State.EMPTY:
		return false
	current_drink = null
	remaining_seconds = 0.0
	_transition_to(State.IDLE, tr("空杯已收起，可以再次点单"))
	return true


## 返回供场景绘制使用的稳定状态名，避免其他模块依赖枚举数字。
func get_state_name() -> StringName:
	match state:
		State.PREPARING:
			return &"preparing"
		State.READY:
			return &"ready"
		State.CARRIED:
			return &"carried"
		State.DRINKING:
			return &"drinking"
		State.EMPTY:
			return &"empty"
		_:
			return &"idle"


## 返回当前状态的友好说明，用于玩家在错误时机点击交互物时给出反馈。
func get_hint() -> String:
	match state:
		State.IDLE:
			return tr("可以前往柜台点一杯饮品")
		State.PREPARING:
			return tr("饮品还在制作中")
		State.READY:
			return tr("饮品已经在取餐台等候")
		State.CARRIED:
			return tr("请带着饮品选择一个座位")
		State.DRINKING:
			return tr("正在安静地喝饮品")
		State.EMPTY:
			return tr("点击空杯上方的续杯气泡")
		_:
			return tr("当前状态未知")


func _transition_to(next_state: State, message: String) -> void:
	state = next_state
	set_process(state == State.PREPARING or state == State.DRINKING)
	state_changed.emit(get_state_name(), message)

