## Базовый функционал локации.
extends BaseArea

class_name Location

@export_category("Base location")
## Путь к директории с уровнями для локации.
@export_dir var levels_dir:String
## После прохождения последнего уровня начинать с первого.
@export var cicle_load_level:bool = true

## Список уровней и путей к ним.
var _levels_dict:Dictionary
## Отсортированный по возрастанию список уровней, запускаются по порядку.
var _levels_sort:PackedStringArray
## Имя загруженного уровня.
var _level_name:String
## Загруженный уровень.
var _level_node:Level = null
## Клюя для словаря состояния с последним пройденным уровнем.
const _key_level_passed = "level_passed"

func _ready():
	super._ready()
	## Строим список уровней для загрузки.
	_levels_dict = _resources.find_all_scene_files_dict(levels_dir)
	_levels_sort = _levels_dict.keys()
	_levels_sort.sort()
	
	## Находим следующий уровень по списку и загружаем его.
	if not _levels_sort.is_empty():
		var location = _resources.state.get(name, {})
		var level_passed = location.get(_key_level_passed, "")
		if level_passed.is_empty() or (cicle_load_level and _levels_sort.find(level_passed) + 1 == _levels_sort.size()):
			_level_node = load_level(_levels_sort[0])
			pass
		else:
			var level_passed_index = _levels_sort.find(level_passed)
			if level_passed_index > -1:
				if level_passed_index + 1 < _levels_sort.size():
					_level_node = load_level(_levels_sort[level_passed_index + 1])
				else:
					location_passed()

func load_level(level_name:String)->Level:
	var packed_scene = load(_levels_dict[level_name])
	if packed_scene && packed_scene.can_instantiate():
		_logs.info("{0} location > load level {1}.".format([name, level_name]))
		var new_node = packed_scene.instantiate() as Level
		_level_name = level_name
		return new_node
	else:
		_logs.error("{0} location > level {1} can not instantiate.".format([name, level_name]))
	return null

## Локация пройдена успешно.
func location_passed():
	pass
	
## Уровень пройден успешно.
func level_passed():
	var location = _resources.state.get(name, {})
	location[_key_level_passed] = _level_name
	_resources.state[name] = location
	_logs.info("{0} location > level {1} passed.".format([name, _level_name]))

