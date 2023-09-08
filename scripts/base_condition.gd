## Условия завершения уровня при скликивании предметов.
extends Resource

class_name BaseItemCondition

## Путь к узлу являющемуся условием.
@export_file("*.tscn") var item_path
## Количество закрытых узлов по условию.
@export_range(1, 1000, 1) var count
## Добавлять ли предмет в инвентарь для последующего вычитания из него(читают в барах статы, напр. жизни).
@export var set_inventory:bool = false
