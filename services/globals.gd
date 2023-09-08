# Глобальные константы и переменные
@tool
extends Node

class_name Globals

## Общие группы которые можно выбрать для предметов, уровней, локаций, инвентаря и т.д. в конфигурации модулей.
enum Groups{
	AREA_ITEM_EVENTS, ## можно использовать для уровней и локаций.
	INVENTORY_ITEM_EVENTS, ## для скликнутых наград в инвентарь.
	INVENTORY_ITEM_CHANGED ## в инвентаре изменилось поле.
}

## Обработчики которые нужно завести на приёмной стороне.
var Group_handlers = {
	Groups.AREA_ITEM_EVENTS:"on_area_item_events", ## По умолчанию в уровнях и локациях.
	Groups.INVENTORY_ITEM_EVENTS:"on_inventory_item_events", ## В инвентаре.
	Groups.INVENTORY_ITEM_CHANGED:"on_inventory_item_changed" ## Для тех кто отслеживает изменения в инвентаре (бары статы).
}

func get_group_name(group:Groups)->String:
	return Groups.keys()[group]
