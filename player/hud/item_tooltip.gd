class_name ItemTooltip extends PanelContainer

var item: Item:
	set(value):
		item = value
		_update_item()

@onready var _title: Label = %Title
@onready var _description: RichTextLabel = %Description

func _update_item() -> void:
	if item == null:
		return
	_title.text = item.name
	_description.text = item.description
