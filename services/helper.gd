@tool
class_name Helper

enum {
	FORMAT_HOURS   = 0x2,
	FORMAT_MINUTES = 0x4,
	FORMAT_SECONDS = 0x8,
	FORMAT_DEFAULT = 0x2 | 0x4 | 0x8
}

const error_str = {
	OK: "No error.",
	FAILED: "Generic error.",
	ERR_UNAVAILABLE: "Unavailable error.",
	ERR_UNCONFIGURED: "Unconfigured error.",
	ERR_UNAUTHORIZED: "Unauthorized error.",
	ERR_PARAMETER_RANGE_ERROR: "Parameter range error.",
	ERR_OUT_OF_MEMORY: "Out of memory (OOM) error.",
	ERR_FILE_NOT_FOUND: "File: Not found error.",
	ERR_FILE_BAD_DRIVE: "File: Bad drive error.",
	ERR_FILE_BAD_PATH: "File: Bad path error.",
	ERR_FILE_NO_PERMISSION: "File: No permission error.",
	ERR_FILE_ALREADY_IN_USE: "File: Already in use error.",
	ERR_FILE_CANT_OPEN: "File: Can't open error.",
	ERR_FILE_CANT_WRITE: "File: Can't write error.",
	ERR_FILE_CANT_READ: "File: Can't read error.",
	ERR_FILE_UNRECOGNIZED: "File: Unrecognized error.",
	ERR_FILE_CORRUPT: "File: Corrupt error.",
	ERR_FILE_MISSING_DEPENDENCIES: "File: Missing dependencies error.",
	ERR_FILE_EOF: "File: End of file (EOF) error.",
	ERR_CANT_OPEN: "Can't open error.",
	ERR_CANT_CREATE: "Can't create error.",
	ERR_QUERY_FAILED: "Query failed error.",
	ERR_ALREADY_IN_USE: "Already in use error.",
	ERR_LOCKED: "Locked error.",
	ERR_TIMEOUT: "Timeout error.",
	ERR_CANT_CONNECT: "Can't connect error.",
	ERR_CANT_RESOLVE: "Can't resolve error.",
	ERR_CONNECTION_ERROR: "Connection error.",
	ERR_CANT_ACQUIRE_RESOURCE: "Can't acquire resource error.",
	ERR_CANT_FORK: "Can't fork process error.",
	ERR_INVALID_DATA: "Invalid data error.",
	ERR_INVALID_PARAMETER: "Invalid parameter error.",
	ERR_ALREADY_EXISTS: "Already exists error.",
	ERR_DOES_NOT_EXIST: "Does not exist error.",
	ERR_DATABASE_CANT_READ: "Database: Read error.",
	ERR_DATABASE_CANT_WRITE: "Database: Write error.",
	ERR_COMPILATION_FAILED: "Compilation failed error.",
	ERR_METHOD_NOT_FOUND: "Method not found error.",
	ERR_LINK_FAILED: "Linking failed error.",
	ERR_SCRIPT_FAILED: "Script failed error.",
	ERR_CYCLIC_LINK: "Cycling link (import cycle) error.",
	ERR_INVALID_DECLARATION: "Invalid declaration error.",
	ERR_DUPLICATE_SYMBOL: "Duplicate symbol error.",
	ERR_PARSE_ERROR: "Parse error.",
	ERR_BUSY: "Busy error.",
	ERR_SKIP: "Skip error.",
	ERR_HELP: "Help error.",
	ERR_BUG: "Bug error.",
	ERR_PRINTER_ON_FIRE: "Printer on fire error. (This is an easter egg, no engine methods return this error code.)"
} 

static func format_timestamp_to_str(time, format = FORMAT_DEFAULT, digit_format = "%02d")->String:
	var digits = []

	if format & FORMAT_HOURS:
		var hours = digit_format % [time / 3600]
		digits.append(hours)

	if format & FORMAT_MINUTES:
		var minutes = digit_format % [time / 60]
		digits.append(minutes)

	if format & FORMAT_SECONDS:
		var seconds = digit_format % [int(ceil(time)) % 60]
		digits.append(seconds)

	var formatted = String()
	var colon = " : "

	for idx in digits.size():
		formatted += digits[idx]
		if idx != digits.size() - 1:
			formatted += colon
	return formatted

static func one_child_visible(child:Node):
	if child:
		var parent = child.get_parent() as Node
		if parent:
			for item in parent.get_children():
				if item == child:
					child.visible = true
				else:
					item.visible = false
