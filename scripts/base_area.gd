## Базовый класс для игрового уровня.
extends Node2D

class_name BaseArea

## Минимальный набор сервисов необходимый для уровня.
var _logs:LoggotLogger = Services.logs
var _resources:Resources = Services.resources
var _globals:Globals = Services.globals
var _inventory:Inventory = Services.inventory

@export_category("Base area")
## Добаиться в группу для получения сообщений о событиях с предметами.
@export var add_to_groups:Array[Globals.Groups]

@export_category("End conditions")
## Условия при которых необходимо завершить уровень.
@export var conditions: Array[BaseItemCondition]
## Условия транслированы в словарь с ключом по идентификатору из предмета. 
var end_conditions:Dictionary
## Когда уровень завершён, отправляем об этом сообщение.
signal send_close()

func _ready():
	for group in add_to_groups:
		add_to_group(_globals.get_group_name(group))
	## Перекладываем условия в более удобный контейнер.
	for condition in conditions:
		var node_res = load(condition.item_path)
		if node_res:
			var item = node_res.instantiate() as BaseItem
			if item:
				end_conditions[item.item_name] = condition.count
				if condition.set_inventory == true:
					_inventory.set_item(item.item_name, condition.count)
				item.queue_free()
			else:
				_logs.error("{0} > error when load condition item path {1}".format([name, condition.item_path]))

## Общий обработчик событий предметов уровня.
func on_area_item_events(item_name:String, event_type:BaseItem.Event, item_count:int):
	match event_type:
		## Предмет удалён.
		BaseItem.Event.CLOSE:
			## Производим перерасчёт условий завершения уровня.
			var calc = end_conditions.get(item_name, -1)
			## Предмета нет в условиях завершения.
			if calc == -1:
				return
			## Перерасчёт условий.
			if calc > 0:
				calc -= 1
				end_conditions[item_name] = calc
			## Часть условия завершилась, удалить его из общего условия.
			if calc == 0:
				end_conditions.erase(item_name)
			## Уведомляем наследников о изменении в условиях.	
			if calc > 0:
				condition_changed(item_name, calc)
			## Все условия выполнены и можно закрывать уровень.	
			if end_conditions.is_empty():
				_logs.info("{0} > close".format([name]))
				close()

## Условие завершения изменилось.
func condition_changed(item_name:String, count:int):
	pass

## Закрываем предмет и уведомляем сигналом об этом подписавшихся.
func close():
	for group in add_to_groups:
		remove_from_group(_globals.get_group_name(group))
	emit_signal("send_close")

