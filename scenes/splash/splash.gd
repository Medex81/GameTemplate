extends TextureRect

var _logs:LoggotLogger = Services.logs

@export_category("Initialization")
@export_file("*.tscn") var next_scene:String


func _ready():
	assert(_logs)
	_logs.info("{0} scene > started.".format([name]))
	if not next_scene.is_empty():
		get_tree().change_scene_to_file(next_scene)
	else:
		_logs.info("{0} scene > next scene not setting.".format([name]))

func _exit_tree():
	_logs.info("{0} scene > exit tree.".format([name]))


