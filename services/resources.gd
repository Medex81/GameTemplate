@tool
extends Node

class_name Resources


#const _timer_timeout = 0.5
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

#var _queue_to_load:PackedStringArray
var _logs:LoggotLogger = Services.logs
#var _timer:Timer = null
#var progress:Array[float]
var make_game_array:PackedStringArray = [_game_locations, _game_scenes]
var make_asset_array:PackedStringArray = [_asset_textures, _asset_levels, _asset_items, _asset_containers]
var state:Dictionary

signal send_resource_loaded(path:String, res:Resource)
signal send_resource_progress(progress:float)

func _ready():
	assert(_logs)
#	_logs.info("{0} service > ready".format([name]))
#	_timer = Timer.new()
#	add_child(_timer)
#	_timer.wait_time = _timer_timeout
#	_timer.timeout.connect(_on_timer_timeout)
	if OS.is_debug_build():
		for game_dir in make_game_array:
			make_dir(get_game_path() + game_dir)
		for asset_dir in make_asset_array:
			make_dir(get_assets_path() + asset_dir)
		#copy_dir_recursive(_addon_resources + _scenes, get_game_path() + _scenes)
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
	

# ================ Assets ================================================
#func find_all_assets_dir_names(assets_type:String)->PackedStringArray:
#	var result:Dictionary
#	find_all_dirs_recursive(get_assets_path(assets_type), result)
#	return result.keys()

#func find_all_assets_cfg_files_dict(assets_type:String)->Dictionary:
#	var result:Dictionary
#	find_all_files_recursive(get_assets_path(assets_type), _cfg_extension, result)
#	return result
	
#func find_all_assets_tscn_files_dict(assets_type:String)->Dictionary:
#	var result:Dictionary
#	find_all_files_recursive(get_assets_path(assets_type), _scene_extension, result)
#	return result
	
#func find_all_assets_tscn_names(assets_type:String)->PackedStringArray:
#	var result:Dictionary
#	find_all_files_recursive(get_assets_path(assets_type), _scene_extension, result)
#	return result.keys()
	
#func find_all_assets_cfg_names(assets_type:String)->PackedStringArray:
#	var result:Dictionary
#	find_all_files_recursive(get_assets_path(assets_type), _cfg_extension, result)
#	return result.keys()
	
#func find_all_assets_sound_names(assets_type:String)->PackedStringArray:
#	var result:Dictionary
#	find_all_files_recursive(get_assets_path(assets_type), _sound_extension, result)
#	return result.keys()


#func get_asset_cfg_dict(assets_type:String, cfg_name:String)->Dictionary:
#	return load_dict_from_cfg_file(get_assets_path(assets_type) + "/" + cfg_name)

#func get_asset_tscn(assets_type:String, scene_name:String)->PackedScene:
#	var _path = get_assets_path(assets_type) + "/" + scene_name + "." + _scene_extension
#	var scene:PackedScene = load(_path)
#	return scene

#func save_asset_cfg(assets_type:String, cfg_name:String, dict:Dictionary):
#	save_dict_to_cfg_file(get_assets_path(assets_type) + "/" + cfg_name, dict)
	
#func get_asset_tscn_path(assets_type:String, scene_name:String):
#	var path = get_assets_path(assets_type) + "/" + scene_name + "." + _scene_extension
#	return path if FileAccess.file_exists(path) else ""
	
#func get_asset_cfg_path(assets_type:String, cfg_name:String):
#	var path = get_assets_path(assets_type) + "/" + cfg_name + "." + _cfg_extension
#	return path if FileAccess.file_exists(path) else ""
	
#func get_asset_sound_path(assets_type:String, sound_name:String):
#	var path = get_assets_path(assets_type) + "/" + sound_name + "." + _sound_extension
#	return path if FileAccess.file_exists(path) else ""

#func remove_asset(assets_type:String, _name:String):
#	remove_file(get_asset_tscn_path(assets_type, _name))
#	remove_file(get_asset_cfg_path(assets_type, _name))
	
#func find_text_in_assets(assets_type:String, find_text:String)->PackedStringArray:
#	var paths = find_all_assets_cfg_files_dict(assets_type)
#	return find_in_text_files(paths, find_text)
	
#func rename_asset(assets_type:String, old_name:String, new_name:String):
#	rename_file(get_asset_tscn_path(assets_type, old_name), new_name)
#	rename_file(get_asset_cfg_path(assets_type, old_name), new_name)
	
#func _get_new_clone_name(assets_type:String, assets_name:String, suffix:String)->String:
#	var new_name = assets_name
#	var assets = find_all_assets_cfg_names(assets_type)
#	while new_name in assets:
#		new_name += suffix
#	return new_name
	
#func clone_asset(assets_type:String, asset_name:String):
#	var new_name = _get_new_clone_name(assets_type, asset_name, _clone_suffix)
#	var old_path = get_asset_cfg_path(assets_type, asset_name)
#	var new_path = get_assets_path(assets_type) + "/" + new_name + "." + _cfg_extension
#	if not old_path.is_empty():
#		if DirAccess.copy_absolute(old_path, new_path) != OK:
#			_logs.error("{0} service > error when copy asset {1} to {2}.".format([name, asset_name, new_path]))
#	else:
#		_logs.error("{0} service > path to asset {1} in {2} not exist.".format([name, asset_name, old_path]))
		
#func create_asset(assets_type:String, dict:Dictionary = {})->String:
#	var new_name = _get_new_clone_name(assets_type, _default_name, _new_suffix)
#	save_asset_cfg(assets_type, new_name, dict)
#	return new_name
# =======================================================================
	
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
