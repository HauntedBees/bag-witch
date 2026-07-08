class_name Item extends Resource

## The item's name.
@export var name: String

## How much inventory space this item takes up.
@export var size: Vector2i

## If the item persists between warps.
@export var persistent := false

## The position and size of the item's icon in item_sheet.png to be used in the inventory grid.
@export var icon: Rect2i

## The path to the 3D scene.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var scene_path: String
