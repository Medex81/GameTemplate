# Ленивая инициализация сервисов, реализация паттерна сервис локатор
# ВАЖНО! Сервисы, к которым нужно обратиться - необходимо инициализировать ДО создания узла(в родителе)!
@tool
extends Node

#var _logger:Logger = null

func _ready():
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
			log.name = "log"
			add_child(log)
		return log

