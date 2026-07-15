extends SceneTree

## 订单状态机的无窗口自动化测试。
##
## 运行：
## HOME=/tmp/coffee-time-godot/home godot4 --headless --path . \
##   --script tests/test_order_controller.gd
##
## 预期：输出 [PASS]，进程退出码为 0。

const OrderControllerScript := preload("res://scripts/orders/order_controller.gd")
const CoffeeDrink: DrinkDefinition = preload("res://data/drinks/coffee.tres")
const TeaDrink: DrinkDefinition = preload("res://data/drinks/tea.tres")
const EXPECTED_TEST_CONSUMPTION_SECONDS := 3.0


func _init() -> void:
	var controller: OrderController = OrderControllerScript.new()
	root.add_child(controller)

	_check(
		is_equal_approx(CoffeeDrink.consumption_seconds, EXPECTED_TEST_CONSUMPTION_SECONDS),
		"coffee uses the short manual-test consumption time"
	)
	_check(
		is_equal_approx(TeaDrink.consumption_seconds, EXPECTED_TEST_CONSUMPTION_SECONDS),
		"tea uses the short manual-test consumption time"
	)
	_check(controller.get_state_name() == &"idle", "initial state is idle")
	_check(not controller.pick_up(), "cannot pick up before ordering")
	_check(controller.place_order(CoffeeDrink), "can place one order")
	_check(controller.get_state_name() == &"preparing", "order enters preparing")
	_check(not controller.place_order(CoffeeDrink), "cannot place a second order")

	controller.remaining_seconds = 0.0
	controller._process(0.0)
	_check(controller.get_state_name() == &"ready", "preparation completes")
	_check(controller.pick_up(), "ready drink can be picked up")
	_check(controller.get_state_name() == &"carried", "pickup enters carried")
	_check(controller.start_drinking(), "carried drink can start drinking")

	controller.remaining_seconds = 0.0
	controller._process(0.0)
	_check(controller.get_state_name() == &"empty", "drinking ends with empty cup")
	_check(controller.dismiss_empty_cup(), "empty cup can be dismissed")
	_check(controller.get_state_name() == &"idle", "dismiss returns to idle")

	print("[PASS] OrderController completes the one-drink loop.")
	quit(0)


func _check(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("[FAIL] %s" % description)
	quit(1)

