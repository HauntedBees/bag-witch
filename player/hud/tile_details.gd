class_name TileDetails extends RefCounted

var tile: InventoryTile
var item: InventoryDetail
var item_display: InventoryItemDisplay

func _init(t: InventoryTile) -> void:
	tile = t

func empty() -> void:
	if item_display:
		item_display.queue_free()
	item_display = null
	item = null
