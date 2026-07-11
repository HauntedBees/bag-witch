class_name Item extends Resource

## The item's name.
@export var name: String

## You don't need me to explain what this is.
@export var description: String

## How much inventory space this item takes up.
@export var size := Vector2i.ONE

## If the item persists between warps.
@export var persistent := false

## The AltasTexture's offset for the equipped sprite (in spell_sheet.png)
@export var equip_sprite_offset := Vector2i.ZERO

## The position and size of the item's icon in item_sheet.png to be used in the inventory grid.
@export var icon: Rect2i

## For items that are tall, not long, I would've had to *think* and *write better code* to handle
## rotation and stuff properly, so the quick solution I've come up with is to *not* do that, and
## just make those items long, too, but rotated by default so they look tall. Brilliant.
@export var rotated_by_default := false

## The path to the 3D scene; should be a WorldItem.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var scene_path: String

## Mostly for use by spells; when the item is equipped, this is used instead of the regular scene.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var custom_equip_scene: String

## The animation the hands should play when this item is in use.
@export var equipped_animation: StringName

## How big the equipped thing should be.
@export var equipped_scale := 1.0

## When true, the equip scene will be on both hands.
@export var both_hands := false

func get_description() -> String:
	return description

func get_equip_instance() -> Node3D:
	var path := scene_path if custom_equip_scene == "" else custom_equip_scene
	var scene: PackedScene = load(path)
	return scene.instantiate()
