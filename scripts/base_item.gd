## Интерактивный игровой предмет.
extends Node2D

class_name BaseItem

enum State{NONE, QUITE_CATCHER, FRAGILE, SOLID}

@export_category("Main")
## Идентификатор предмета.
@export var item_name:String
## Начисляется предметов в инвентарь.
@export var item_count:int = 1
@export_category("Container")
## Из предмета выпадает контейнер.
@export_file("*.tscn") var drop_container:String
## Вероятность выпадения предмета из контейнера.
@export var drop_probability:int = 100
@export_category("Interaction")
## Очки жизни
@export_range(0, 1000, 1) var hitpoint: = 0
## Наносимый урон
@export_range(0, 1000, 1) var damage: = 0
## Предмет с таким флагом уничтожает все с чем сталкивается не отправляя сообщений.
@export var state:State = State.NONE
@export_category("Events")
## Отправлять события предмета в группы.
@export var send_to_groups:Array[Globals.Groups]

var _globals:Globals = Services.globals
## Узел контейнера с дропом.
var _drop:BaseItemContainer = null
## События предмета.
enum Event{CLOSE}

func _ready():
	## Инстансим контейнер, но не инитим его через рейди добавляя в чаилды.
	if not drop_container.is_empty():
		var drop_res = load(drop_container)
		if drop_res:
			_drop = drop_res.instantiate() as BaseItemContainer
			_drop.visible = false

## Произошла коллизия с другим предметом.
func calc_collision(node):
	## Конфигурационная часть находится у родителя.
	var second = node.get_parent()
	if second is BaseItem:
		## Уловитель удаляет всё с чем сталкивается без уведомления событием
		if second.state == State.QUITE_CATCHER:
			close(false)
			return
		if state == State.QUITE_CATCHER:
			second.close(false)
			return
		## Хрупкий предмет разбивается о любое препятствие с уведомлением событием.
		if second.state == State.FRAGILE:
			second.close()
			return
		if state == State.FRAGILE:
			close()
			return
		## Твёрдый предмет разбивает о себя любой предмет с уведомлением событием.
		if second.state == State.SOLID:
			close()
			return
		if state == State.SOLID:
			second.close()
			return
		## Расчёт хп по дамагу.
		if second.damage > 0 and hitpoint > 0:
			hitpoint = hitpoint - second.damage
			if hitpoint < 1:
				close()
				return
		if damage > 0 and second.hitpoint > 0:
			second.hitpoint = second.hitpoint - damage
			if second.hitpoint < 1:
				second.close()
				return
				
func close(send_call:bool = true):
	if send_call:
		## Уведомляем указанные группы о своём закрытии.
		for group in send_to_groups:
			get_tree().call_group(_globals.get_group_name(group), _globals.Group_handlers[group], item_name, Event.CLOSE, item_count)
		## Дропаем контейнер с предметами, если есть.
		if _drop:
			visible = false
			_drop.visible = true
			get_parent().call_deferred("add_child", _drop)
			_drop.position = position
	queue_free()
