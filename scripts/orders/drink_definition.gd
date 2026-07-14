class_name DrinkDefinition
extends Resource

## 一种可点饮品的数据定义。
##
## 资源文件位于 res://data/drinks/。逻辑脚本只读取这些参数，避免把饮品名称和
## 计时写死在订单状态机里。

## 稳定 ID，用于未来存档与多人同步。修改显示名称时不要修改此值。
@export var id: StringName

## 点单菜单显示名称。首版使用中文原文，未来通过翻译资源提供其他语言。
@export var display_name: String

## 咖啡师制作所需时间，单位：秒。
@export_range(1.0, 180.0, 1.0) var preparation_seconds: float = 15.0

## 原型饮用时间，单位：秒。正式内容会改为约 20–30 分钟。
@export_range(10.0, 3600.0, 1.0) var consumption_seconds: float = 60.0

