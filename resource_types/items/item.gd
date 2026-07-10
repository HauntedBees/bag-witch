class_name Item extends Resource

## The item's name.
@export var name: String

## You don't need me to explain what this is.
@export var description: String

## How much inventory space this item takes up.
@export var size := Vector2i.ONE

## If the item persists between warps.
@export var persistent := false

## The position and size of the item's icon in item_sheet.png to be used in the inventory grid.
@export var icon: Rect2i

## The path to the 3D scene; should be a WorldItem.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var scene_path: String

func get_description() -> String:
	return description
