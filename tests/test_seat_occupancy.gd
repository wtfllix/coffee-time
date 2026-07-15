extends SceneTree

## 座位占用与玩家优先规则的无窗口自动化测试。
##
## 运行：godot4 --headless --path . --script tests/test_seat_occupancy.gd
## 预期：输出 [PASS]，进程退出码为 0。

const SeatOccupancyScript := preload("res://scripts/actors/seat_occupancy.gd")

var failure_count: int = 0


func _init() -> void:
	var occupancy := SeatOccupancyScript.new()
	occupancy.configure(8, [1, 6], 2)

	_check(occupancy.get_customer_seat_indices() == [1, 6], "two requested customer seats are occupied")
	_check(occupancy.get_player_accessible_seat_count() == 6, "six seats remain accessible to the player")
	_check(not occupancy.claim_player_seat(1), "player cannot claim a customer seat")
	_check(occupancy.claim_player_seat(0), "player can claim an available seat")

	# 顾客重新分配时必须跳过玩家座位，并始终保留至少两个玩家可用座位。
	occupancy.configure(8, [0, 1, 2, 3, 4, 5, 6, 7], 2)
	_check(not occupancy.is_customer_seat(0), "customer assignment preserves the claimed player seat")
	_check(occupancy.get_player_accessible_seat_count() >= 2, "at least two seats remain player-accessible")
	_check(occupancy.player_seat_index == 0, "player keeps the claimed seat after customer reassignment")

	if failure_count > 0:
		quit(1)
		return
	print("[PASS] SeatOccupancy preserves player priority and minimum available seating.")
	quit(0)


func _check(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("[FAIL] %s" % description)
	failure_count += 1
