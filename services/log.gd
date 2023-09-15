## Сервис логирования.
extends Node

class_name Log
## Уровни логирования.
enum Level {TRACE, DEBUG, INFO, WARN, ERROR}
const _trace = "TRACE|"
const _debug = "DEBUG|"
const _info = "INFO|"
const _warn = "WARN|"
const _error = "ERROR|"
## Формат времени в логе.
const time_without_utc = false
## Сколько сообщений буферируем перед сбросом на диск.
const _message_buffer_size = 10
const _log_file = "user://log.txt"
## Максимальный размер файла лога.
const _max_file_size = 1000000
## Текущий уровень логирования.
var _level:int = Level.DEBUG
## Отдельный поток для записи лога на диск.
var _guard:Mutex
var _semaphore:Semaphore
var _thread:Thread
## Двойное буферирование сообщений, в один пишем из другого сбрасываем на диск.
var _write_string_pack:PackedStringArray
var _upload_string_pack:PackedStringArray
var _tmp_pack:PackedStringArray
## Флаг завершения потока.
var _exit_thread = false

func _ready():
	_guard = Mutex.new()
	_semaphore = Semaphore.new()
	_thread = Thread.new()
	_thread.start(_thread_append_events)
	info("")
	info("{0} service > ready".format([name]))
	
func _exit_tree():
	_exit_thread = true
	upload_to_file()

func set_level(level : int):
	_level = level

func _add_message_to_buffer(type:String, message:String):
	_write_string_pack.append(type + Time.get_datetime_string_from_system(time_without_utc) + "|" + message)
	if OS.is_debug_build():
		print(_write_string_pack[_write_string_pack.size() - 1])
	if _write_string_pack.size() > _message_buffer_size:
		upload_to_file()

func trace(message:String):
	if Level.TRACE >= _level:
		_add_message_to_buffer(_trace, message)

func debug(message:String):
	if Level.DEBUG >= _level:
		_add_message_to_buffer(_debug, message)

func info(message:String):
	if Level.INFO >= _level:
		_add_message_to_buffer(_info, message)

func warn(message:String):
	if Level.WARN >= _level:
		_add_message_to_buffer(_warn, message)

func error(message:String):
	if Level.ERROR >= _level:
		_add_message_to_buffer(_error, message)

func upload_to_file():
	_guard.lock()
	_tmp_pack = _upload_string_pack
	_upload_string_pack = _write_string_pack
	_write_string_pack = _tmp_pack
	_guard.unlock()
	_semaphore.post()

func _thread_append_events():
	var file:FileAccess = null
	if FileAccess.file_exists(_log_file):
		## Если файл существует открываем и переходим в конец.
		file = FileAccess.open(_log_file, FileAccess.READ_WRITE)
		file.seek_end(-1)
		## Если файл больше максимального размера сохраняем его с другим именем и открываем со старым сначала.
		if file.get_position() > _max_file_size:
			file.close()
			DirAccess.rename_absolute(_log_file, "user://{0}.txt".format([Time.get_datetime_string_from_system(time_without_utc)]))
			file = FileAccess.open(_log_file, FileAccess.WRITE)
	else:
		file = FileAccess.open(_log_file, FileAccess.WRITE)
		
	while true:
		_semaphore.wait()
		for message in _upload_string_pack:
			file.store_line(message)
		file.flush()
		_guard.lock()
		var should_exit = _exit_thread
		_guard.unlock()

		if should_exit:
			break
