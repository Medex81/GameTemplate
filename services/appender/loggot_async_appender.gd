extends LoggotAppender
class_name LoggotAsyncAppender

var _guard : Mutex
var _semaphore : Semaphore
var _thread : Thread
var _exit_thread = false
var _queue_size = 256
var _events_queue = []
var _appender : LoggotAppender = null

func _init(appender : LoggotAppender):
	if appender:
		_guard = Mutex.new()
		_semaphore = Semaphore.new()
		_thread = Thread.new()
		_appender = appender

func do_append(event : LoggotEvent):
	if !_appender:
		return
		
	_guard.lock()
	_events_queue.append(event)
	# TODO improve pop queue
	if len(_events_queue) > _queue_size:
		_events_queue.pop_front()
	_guard.unlock()
	_semaphore.post()

func get_name()->String:
	return _appender.get_name() if _appender else "no appender"

func start():
	if _appender:
		_appender.start()
		_thread.start(Callable(self,"_thread_append_events"))

func stop():
	if _appender:
		_guard.lock()
		_exit_thread = true
		_guard.unlock()
		# authorize a thread run
		_semaphore.post()
		# Wait until it exits.
		_thread.wait_to_finish()
		_appender.stop()

func is_started()->bool:
	return _thread.is_started()

func flush():
	if _appender:
		_appender.flush()

func _thread_append_events():
	while true:
		_semaphore.wait()
		_guard.lock()
		var should_exit = _exit_thread
		_guard.unlock()

		if should_exit:
			break

		if len(_events_queue) == 0:
			continue
		else:
			_guard.lock()
			var events_to_append = _events_queue.duplicate()
			_events_queue.clear()
			_guard.unlock()
			for event in events_to_append:
				_appender.do_append(event)
