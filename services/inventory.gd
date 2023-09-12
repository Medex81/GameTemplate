## Сервис инвентаря.
@tool
extends Node

class_name Inventory

var _logs:LoggotLogger = Services.logs
var _resources:Resources = Services.resources
var _globals:Globals = Services.globals

func _ready():
	## Из этой группы будем получать события предметов для инвентаря(определена в глобальном скрипте).
	add_to_group(_globals.get_group_name(Globals.Groups.INVENTORY_ITEM_EVENTS))

## Отправим сообщение в подписавшиеся бары статы с текущим накопленным счётом по предмету.
func send_to_bars(item_name:String, item_count:int, begin_value:bool = false):
	get_tree().call_group(_globals.get_group_name(Globals.Groups.INVENTORY_ITEM_CHANGED),
	 _globals.Group_handlers[Globals.Groups.INVENTORY_ITEM_CHANGED], item_name, item_count, begin_value)
	
## Общий обработчик событий предметов подписанных на инвентарь.
func on_inventory_item_events(item_name:String, event_type:BaseItem.Event, item_count:int):
	var inventory = _resources.state.get(name, {})
	var value = inventory.get(item_name, 0)
	inventory[item_name] = value + item_count
	if inventory[item_name] < 0:
		inventory[item_name] = 0
	_resources.state[name] = inventory
	send_to_bars(item_name, inventory[item_name])
	
## Иногда нам нужно установить в инвентарь точное количество предметов.
func set_item(item_name:String, item_count:int):
	var inventory = _resources.state.get(name, {})
	inventory[item_name] = item_count
	if inventory[item_name] < 0:
		inventory[item_name] = 0
	_resources.state[name] = inventory
	send_to_bars(item_name, inventory[item_name], true)
	
func get_item(item_name:String)->int:
	var inventory = _resources.state.get(name, {})
	return inventory.get(item_name, 0)
	
## Перед списанием проверим есть ли у игрока достаточно предметов для покупки.
func has_item(item_name:String, item_count:int)->bool:
	var inventory = _resources.state.get(name, {})
	if inventory[item_name] < item_count:
		return false
	return true
	
## Списываем предметы из инвентаря.
func spend_item(item_name:String, item_count:int)->bool:
	var inventory = _resources.state.get(name, {})
	if inventory[item_name] < item_count:
		return false
	inventory[item_name] -= item_count
	_resources.state[name] = inventory
	send_to_bars(item_name, inventory[item_name])
	return true
