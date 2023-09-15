extends Control

class_name BaseScene

var _logs:Log = Services.log
var _shadow = preload("res://addons/GameTemplate/scenes/scene_hide_show/shadow.tscn").instantiate()

@export_category("At start")
@export var _show_on_start:bool = true

@export_category("At end")
@export_file("*.tscn") var next_scene:String

func _ready():
	assert(_logs)
	_logs.info("{0} scene > started.".format([name]))
	add_child(_shadow)
	_shadow.send_hide.connect(shadow_hide)
	_shadow.send_show.connect(shadow_show)
	if _show_on_start:
		_shadow.shadow_show()

func _exit_tree():
	_logs.info("{0} scene > exit tree.".format([name]))
	
func final():
	_shadow.shadow_hide()
	
func shadow_hide():
	## load next scene
	get_tree().change_scene_to_file(next_scene)
	
func shadow_show():
	pass
