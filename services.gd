# Ленивая инициализация сервисов, реализация паттерна сервис локатор
# ВАЖНО! Сервисы, к которым нужно обратиться - необходимо инициализировать ДО создания узла(в родителе)!
@tool
extends Node

var _logger:Logger = null

func _ready():
	# Логер запускаем отдельно и первым для установки его инстанса
	_logger = load("res://addons/GameTemplate/services/logger.gd").new()
	if _logger:
		add_child(_logger)
		
	## Инициализируем минимальный набор сервисов необходимый в каждой игре
	resources
	inventory
	
var inventory:Inventory = null :
	get:
		if !inventory:
			inventory = Inventory.new()
			inventory.name = "inventory"
			add_child(inventory)
		return inventory
		
var logs:LoggotLogger = null :
	get:
		if !logs:
			if _logger == null:
				_ready()
			logs = _logger.get_logger()
			# пресет логера для отладки - собираем более широкую воронку
			if OS.is_debug_build():
				logs.attach_appender(LoggotAsyncAppender.new(LoggotFileAppender.new()))
				logs.attach_appender(LoggotAsyncAppender.new(LoggotConsoleAppender.new()))
				logs.set_level(LoggotConstants.Level.DEBUG)
			else:
				# пресет для релиза - берем только предупреждения и ошибки
				logs.attach_appender(LoggotAsyncAppender.new(LoggotFileAppender.new()))
				logs.set_level(LoggotConstants.Level.WARN)
		return logs
		
var resources:Resources = null :
	get:
		if !resources:
			resources = Resources.new()
			resources.name = "resources"
			add_child(resources)
		return resources
		
var globals:Globals = null :
	get:
		if !globals:
			globals = Globals.new()
			add_child(globals)
		return globals
		
var log:Log = null :
	get:
		if !log:
			log = Log.new()
			add_child(log)
		return log

