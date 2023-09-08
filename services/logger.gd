@tool
extends  Node

class_name Logger

signal stopped_and_flushed()

var _loggers = {}
const FLUSH_RATE_SEC = 5
var _last_flush_time = 0

func get_logger(name:String = "default") -> LoggotLogger :
	if _loggers.has(name):
		return _loggers[name]
	else:
		var logger = LoggotLogger.new(LoggotConstants.Level.DEBUG, name)
		_loggers[name] = logger
		return _loggers[name]

func flush():
	for name in _loggers:
		_loggers[name].flush()

func stop_and_flush():
	for name in _loggers:
		_loggers[name].stop()
		_loggers[name].flush()
	emit_signal("stopped_and_flushed")

func _process(delta):
	_last_flush_time += delta
	if _last_flush_time >= FLUSH_RATE_SEC:
		_last_flush_time = 0
		flush()
	
func _exit_tree():
	stop_and_flush()
