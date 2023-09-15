extends Node

class_name BaseService

var _logs:Log = Services.log

func _ready():
	_logs.info("{0} service > ready".format([name]))

	
func _exit_tree():
	_logs.info("{0} service > exit tree".format([name]))
