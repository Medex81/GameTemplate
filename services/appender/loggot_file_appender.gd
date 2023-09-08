extends LoggotAppender
class_name LoggotFileAppender

const CUR_LOG_PATH = "user://loggot4/current_log.txt"
const LOGS_ARCHIVE = "user://loggot4/zip_archive"
const CUR_ZIP_PATH = "user://loggot4/zip_archive/%s_loggot4.zip"
const MAX_CUR_LOG_SIZE_BYTES = 3145728 # 3 Mb

var _encoder : LoggotEncoder = null
var _file : FileAccess = null

func _init(encoder : LoggotEncoder = null):
	_encoder = encoder if encoder != null else LoggotEncoderDefault.new()

func do_append(event : LoggotEvent):
	if _file:
		_file.store_line(_encoder.encode(event))

func flush():
	if _file:
		_file.flush()

func get_name()->String:
	return "LoggotFileAppender"
	
func _write_zip_file():
	var writer = ZIPPacker.new()
	var err = writer.open(CUR_ZIP_PATH % Time.get_datetime_string_from_system(true))
	if err != OK:
		return err
	writer.start_file("log.txt")
	writer.write_file(FileAccess.get_file_as_bytes(CUR_LOG_PATH));
	writer.close_file()
	writer.close()
	return OK

func start()->bool:
	if !DirAccess.dir_exists_absolute(LOGS_ARCHIVE):
		var err = DirAccess.make_dir_recursive_absolute(LOGS_ARCHIVE)
		if err:
			LoggotConstants.emit_loggot_error("Could not create %s; exited with error %d." % [LOGS_ARCHIVE, err])
			return false
		
	_file = FileAccess.open(CUR_LOG_PATH, FileAccess.READ_WRITE)
	if _file && _file.get_length() > MAX_CUR_LOG_SIZE_BYTES:
		stop()
		_write_zip_file()
		DirAccess.remove_absolute(CUR_LOG_PATH)
		
	if _file == null:
		_file = FileAccess.open(CUR_LOG_PATH, FileAccess.WRITE)

	if _file != null:
		_file.seek_end()
		return true
	
	return false

func stop():
	_file = null

func is_started()->bool:
	return _file != null
