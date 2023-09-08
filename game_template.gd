@tool
extends EditorPlugin

const _AUTOLOAD_NAME = "Services"

func _enter_tree():
	add_autoload_singleton(_AUTOLOAD_NAME,"res://addons/GameTemplate/services.gd" )

func _exit_tree():
	remove_autoload_singleton(_AUTOLOAD_NAME)
		
func _get_plugin_name():
	return "Game template"

