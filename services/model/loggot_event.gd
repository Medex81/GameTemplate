class_name LoggotEvent

var origin
var time
var level:LoggotConstants.Level
var message:String
var args:Array

func _init(origin, time, level:LoggotConstants.Level, message:String, args:Array):
	self.origin = origin
	self.time = time
	self.level = level
	self.message = message
	self.args = args


