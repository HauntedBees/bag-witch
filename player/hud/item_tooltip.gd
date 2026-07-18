class_name ItemTooltip extends MarginContainer

var item: InventoryDetail:
	set(value):
		item = value
		if !is_inside_tree():
			await ready
		_update_item()

@onready var _title: Label = %Title
@onready var _description: RichTextLabel = %Description

func _update_item() -> void:
	if item == null:
		return
	_title.text = item.get_item_name()
	_description.text = item.item.get_description(item)
