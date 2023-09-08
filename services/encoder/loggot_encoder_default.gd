extends LoggotEncoder
class_name LoggotEncoderDefault


const MARKER_TIME = "{TIME}"
const MARKER_LEVEL = "{LVL}"
const MARKER_ORIGIN = "{ORGN}"
const MARKER_MESSAGE = "{MSG}"
const DEFAULT_FORMAT = "{TIME} {LVL} {ORGN}: {MSG}"

const LevelNames = {
	LoggotConstants.Level.TRACE:"TRACE",
	LoggotConstants.Level.DEBUG:"DEBUG",
	LoggotConstants.Level.INFO:"INFO",
	LoggotConstants.Level.WARN:"WARN",
	LoggotConstants.Level.ERROR:"ERROR"
}

var _format : String


func _init(format = DEFAULT_FORMAT):
	_format = format


func encode(event : LoggotEvent):
	var result = _format.replace(MARKER_TIME, str(event.time))
	result = result.replace(MARKER_LEVEL, LevelNames[event.level])
	result = result.replace(MARKER_ORIGIN, str(event.origin))
	result = result.replace(MARKER_MESSAGE, event.message)
	return result
