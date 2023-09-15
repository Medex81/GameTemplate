@tool
extends BaseService

class_name Resources

# Путь к файлам конфигурации интерактивов
const _addon_resources = "res://addons/GameTemplate/"
const _res_path = "res://"
const _user_path = "user://"
const _assets_path = "assets/"
const _game_path = "game/"
const _game_locations = "locations"
const _game_scenes = "scenes"
const _asset_textures = "textures"
const _asset_levels = "levels"
const _asset_items = "items"
const _asset_containers = "containers"
const _cfg_extension = "json"
const _scene_extension = "tscn"
const _script_extension = "gd"
const _sound_extension = "ogg"
const _pwd = ""
const _state_name = "state"
const _scenes = "scenes"
const _copy_to_game = "copy_to_game"

var make_game_array:PackedStringArray = [_game_locations, _game_scenes]
var make_asset_array:PackedStringArray = [_asset_textures, _asset_levels, _asset_items, _asset_containers]
var state:Dictionary

func _ready():
	super._ready()
	if OS.is_debug_build():
		for game_dir in make_game_array:
			make_dir(get_game_path() + game_dir)
		for asset_dir in make_asset_array:
			make_dir(get_assets_path() + asset_dir)
		copy_dir_recursive(_addon_resources + _scenes + "/" + _copy_to_game, get_game_path() + _scenes)
	load_state()
	
func copy_dir_recursive(from_dir:String, to_dir:String): ## <--
	var dir = DirAccess.open(from_dir)
	if dir:
		dir.list_dir_begin()
		while true:
			var next_item = dir.get_next()
			if next_item.is_empty():
				break
			if dir.current_is_dir() && next_item != "." && next_item != "..":
				DirAccess.make_dir_absolute(to_dir + "/" + next_item)
				copy_dir_recursive(dir.get_current_dir() + "/" + next_item + "/", to_dir + "/" + next_item)
			else:
				if not FileAccess.file_exists(to_dir + "/" + next_item):
					DirAccess.copy_absolute(dir.get_current_dir() + "/" + next_item, to_dir + "/" + next_item)
		dir.list_dir_end()
	else:
		_logs.error("{0} service > An error occurred when trying to access the path {1}".format([name, from_dir]))
	
func find_all_files_recursive(find_dir:String, extension:String, paths:Dictionary): ## <--
	var dir = DirAccess.open(find_dir)
	if dir:
		dir.list_dir_begin()
		while true:
			var next_item = dir.get_next()
			if next_item.is_empty()|| ".import" in next_item:
				break
			if dir.current_is_dir() && next_item != "." && next_item != "..":
				find_all_files_recursive(dir.get_current_dir() + "/" + next_item + "/", extension, paths)
			elif next_item.get_extension() == extension:
				if paths.has(next_item.get_basename()):
					_logs.error("{0} service >  Duplicate resources {1}".format([name, next_item]))
				paths[next_item.get_basename()] = dir.get_current_dir() + "/" + next_item
				_logs.info("{0} service > Add path to resource - {1}".format([name, next_item.get_basename()]))
		dir.list_dir_end()
	else:
		_logs.error("{0} service > An error occurred when trying to access the path {1}".format([name, find_dir]))
		
func find_all_dirs_recursive(find_dir:String, paths:Dictionary): ## <--
	var dir = DirAccess.open(find_dir)
	if dir:
		dir.list_dir_begin()
		while true:
			var next_item = dir.get_next().replace(".import", "")
			if next_item.is_empty():
				break
			if dir.current_is_dir() && next_item != "." && next_item != "..":
				find_all_dirs_recursive(dir.get_current_dir() + "/" + next_item + "/", paths)
				paths[next_item.get_basename()] = dir.get_current_dir() + "/" + next_item
		dir.list_dir_end()
	else:
		_logs.error("{0} service > An error occurred when trying to access the path {1}".format([name, find_dir]))
	
func find_all_files_dict(start_dir:String, extension:String)->Dictionary: ## <-- 
	var result:Dictionary
	find_all_files_recursive(start_dir, extension, result)
	return result
	
func get_path_to_addon_resources()->String:
	return _addon_resources

func find_all_scene_files_dict(start_dir:String)->Dictionary: ## <--
	var result:Dictionary
	find_all_files_recursive(start_dir, _scene_extension, result)
	return result

func get_game_path()->String: ## <--
	var res_dir_path = _res_path + _game_path
	var user_dir_path = _user_path + _game_path
	# В отладке создадим директорию в ресурсах если её нет
	if OS.is_debug_build():
		make_dir(res_dir_path)
	
	if DirAccess.dir_exists_absolute(user_dir_path):
		return user_dir_path
		
	if DirAccess.dir_exists_absolute(res_dir_path):
		return res_dir_path
		
	_logs.error("{0} service > path to game resource directory {1} not exist.".format([name, _game_path]))
	return ""

func make_dir(path:String):
	if !DirAccess.dir_exists_absolute(path):
		var state = DirAccess.make_dir_recursive_absolute(path)
		if state != OK:
			_logs.error("{0} service > error when make dir {1}, {2}".format([name, path, Helper.error_str[state]]))

func get_assets_path()->String:
	var res_dir_path = _res_path + _assets_path
	var user_dir_path = _user_path + _assets_path
	# В отладке создадим директорию в ресурсах если её нет
	if OS.is_debug_build():
		make_dir(res_dir_path)
	
	if DirAccess.dir_exists_absolute(user_dir_path):
		return user_dir_path
		
	if DirAccess.dir_exists_absolute(res_dir_path):
		return res_dir_path
		
	_logs.error("{0} service > path to assets directory {1} not exist.".format([name, _assets_path]))
	return ""

func save_dict_to_cfg_file(path:String, dict:Dictionary):
	var _path = path + "." + _cfg_extension
	_logs.info("{0} service > save file: {1}".format([name, _path]))
	var file = FileAccess.open_encrypted_with_pass(_path, FileAccess.WRITE, _pwd) if !OS.is_debug_build() else FileAccess.open(_path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(dict))
	else:
		var message = "{0} service > File error(save):{1}, {2}".format([name, Helper.error_str[FileAccess.get_open_error()], _path])
		OS.alert(message)
		
func get_pwd()->String:
	return _pwd
	
		
func load_dict_from_cfg_file(path:String)->Dictionary:
	var _path = path + "." + _cfg_extension
	if FileAccess.file_exists(_path):
		var file = FileAccess.open_encrypted_with_pass(_path, FileAccess.READ, _pwd) if !OS.is_debug_build() else FileAccess.open(_path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var state = json.parse(file.get_as_text(true))
			if state == OK:
				_logs.info("{0} service > load file: {1}".format([name,_path]))
				return json.data
			else:
				var message = "{0} service > JSON Parse Error:{1} at line {2}, {3}".format([name, json.get_error_message(), json.get_error_line(), path])
				OS.alert(message)
		else:
			var message = "{0} service > File error(load):{1}, {2}".format([name, Helper.error_str[FileAccess.get_open_error()], _path])
			OS.alert(message)

	return {}

func save_state():
	save_dict_to_cfg_file("{0}{1}".format([_user_path, _state_name]), state)
	
func load_state():
	state = load_dict_from_cfg_file("{0}{1}".format([_user_path, _state_name]))
	pass
#========================================================================
	
func find_all_files_array(start_dir:String, extension:String)->Array:
	return find_all_files_dict(start_dir, extension).keys()
	
func find_all_cfg_files_dict(start_dir:String)->Dictionary:
	var result:Dictionary
	find_all_files_recursive(start_dir, _cfg_extension, result)
	return result

func find_all_cfg_files_array(start_dir:String)->Array:
	return find_all_files_dict(start_dir, _cfg_extension).keys()
	
func find_all_scene_files_array(start_dir:String)->Array:
	return find_all_files_dict(start_dir, _scene_extension).keys()
			
func remove_file(path:String):
	DirAccess.remove_absolute(path)

func find_in_text_files(paths:Dictionary, find_text:String)->PackedStringArray:
	var result:PackedStringArray
	for _name in paths:
		if _name.to_lower().findn(find_text) > -1 || FileAccess.get_file_as_string(paths[_name]).to_lower().findn(find_text) > -1:
			result.append(_name)
	return result

func _change_file(old_file_path:String, new_name:String, func_pointer):
	if FileAccess.file_exists(old_file_path):
		var old_name = old_file_path.get_file()
		var new_path = old_file_path.replace(old_name, new_name + "." + old_file_path.get_extension())
		var state = func_pointer.call(old_file_path, new_path)
		if state != OK:
			_logs.error("{0} service > {1}".format([name, Helper.error_str[state]]))
	else:
		_logs.error("{0} service > file {1} not exist or access denied.".format([name, old_file_path]))

func rename_file(old_file_path:String, new_name:String):
	_change_file(old_file_path, new_name, DirAccess.rename_absolute)

func copy_file(old_file_path:String, new_name:String):
	_change_file(old_file_path, new_name, DirAccess.copy_absolute)
