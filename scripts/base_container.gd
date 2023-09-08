## Контейнер с предметами для дропа.
extends Node2D

class_name BaseItemContainer

## Минимальное количество предметов выпадающих из контейнера.
@export_range(0, 10, 1) var min_drop_count:int = 1
## Максимальное количество предметов выпадающих из контейнера.
@export_range(0, 10, 1) var max_drop_count:int = 10
@export var split_expance:int = 60

func _ready():
	## Сортируем дочерние узлы по проценту выпадения.
	var children = get_children()
	children.sort_custom(func(a,b): return a.drop_probability < b.drop_probability)
	## От наименьшего начинаем рандомно проверять выпадение предмета.
	randomize()
	var approve:Array
	for child in children:
		## Проверяем не выпало ли предметов равно максимуму
		if randi() % 100 <= child.drop_probability and approve.size() < max_drop_count:
			approve.append(child)
	## Дошли до конца массива, если выпало меньше минимума - дополняем предметами с максимальным процентом
	if approve.size() < min_drop_count:
		children.sort_custom(func(a,b): return a.drop_probability > b.drop_probability)
		for child in children:
			if child not in approve and approve.size() < min_drop_count:
				approve.append(child)
	for child in children:
		if child not in approve:
			child.close(false)
	## Размещаем выпавшие предметы на указанном расстоянии по горизонтали друг от друга относительно центра.
	var split = -(approve.size() / 2) * split_expance
	for child in approve:
		child.position.x = split
		split += split_expance
