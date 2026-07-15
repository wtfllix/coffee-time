class_name SeatOccupancy
extends RefCounted

## 原型座位占用规则。
##
## 职责：记录顾客与玩家占座，并为玩家保留最少可用座位。
## 输入：座位总数、期望的顾客座位索引和玩家选座。
## 输出：稳定的占用查询结果，供场景绘制、寻路和交互判断使用。
## 依赖：无；由 res://scripts/cafe/cafe_prototype.gd 创建。

var total_seat_count: int = 0
var minimum_player_seats: int = 0
var customer_seat_indices: Array[int] = []
var player_seat_index: int = -1


## 配置顾客座位。顾客不会占用玩家已选座位，并至少留下 minimum_available 个玩家可用座位。
func configure(
	seat_count: int,
	requested_customer_seats: Array[int],
	minimum_available: int
) -> void:
	total_seat_count = maxi(0, seat_count)
	minimum_player_seats = clampi(minimum_available, 0, total_seat_count)
	customer_seat_indices.clear()

	var maximum_customer_count := total_seat_count - minimum_player_seats
	for seat_index in requested_customer_seats:
		if customer_seat_indices.size() >= maximum_customer_count:
			break
		if not _is_valid_seat(seat_index):
			continue
		if seat_index == player_seat_index or customer_seat_indices.has(seat_index):
			continue
		customer_seat_indices.append(seat_index)

	if not _is_valid_seat(player_seat_index):
		player_seat_index = -1


## 玩家尝试占座。顾客已占用或越界时返回 false，成功时自动释放原玩家座位。
func claim_player_seat(seat_index: int) -> bool:
	if not is_available_for_player(seat_index):
		return false
	player_seat_index = seat_index
	return true


## 玩家离座，允许之后选择其他空座。
func release_player_seat() -> void:
	player_seat_index = -1


## 返回指定座位是否由占位顾客使用。
func is_customer_seat(seat_index: int) -> bool:
	return customer_seat_indices.has(seat_index)


## 返回玩家是否可以选择指定座位。
func is_available_for_player(seat_index: int) -> bool:
	return _is_valid_seat(seat_index) and not is_customer_seat(seat_index)


## 返回顾客座位副本，避免调用方直接修改内部状态。
func get_customer_seat_indices() -> Array[int]:
	return customer_seat_indices.duplicate()


## 返回没有被顾客占用、可供玩家使用的座位数量。
func get_player_accessible_seat_count() -> int:
	return total_seat_count - customer_seat_indices.size()


func _is_valid_seat(seat_index: int) -> bool:
	return seat_index >= 0 and seat_index < total_seat_count
