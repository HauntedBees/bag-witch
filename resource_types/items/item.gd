class_name Item extends Resource

@export_category("Basic Details")

## The item's name.
@export var name: String

## You don't need me to explain what this is.
@export_multiline() var description: String

## How much inventory space this item takes up.
@export var size := Vector2i.ONE

## The position and size of the item's icon in item_sheet.png to be used in the inventory grid.
@export var icon := Rect2i(0, 0, 1, 1)

## For items that are tall, not long, I would've had to *think* and *write better code* to handle
## rotation and stuff properly, so the quick solution I've come up with is to *not* do that, and
## just make those items long, too, but rotated by default so they look tall. Brilliant.
@export var rotated_by_default := false
## The path to the 3D scene; should be a WorldItem.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var scene_path: String

## Things that can be sawed in half.
@export var can_be_sawed := false

## What this item becomes when it is sawed in half.
@export var sawable_item: Item

@export_category("Equipping")

## Single-use items.
@export var discard_on_use := false

## The maximum distance from an enemy the player must be for the Item Select to show up.
@export_range(0.0, 30.0) var use_range := 1.0

## The AltasTexture's offset for the equipped sprite (in spell_sheet.png)
@export var equip_sprite_offset := Vector2i.ZERO

## Mostly for use by spells; when the item is equipped, this is used instead of the regular scene.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var custom_equip_scene: String

## The animation the hands should play when this item is equipped (not *being* equipped).
@export var equipped_animation: StringName

## The animation the hands should play when this item is actively used.
@export var use_animation: StringName

@export var use_animation_speed := 1.0

## If set, this is the animation the hands should play every other time this item is actively used.
@export var alt_use_animation: StringName

## The animation the hands should play when this item is reloaded.
@export var reload_animation: StringName

## The time it takes to reload the weapon.
@export var reload_time := 0.0

## How big the equipped thing should be.
@export var equipped_scale := 1.0

## When true, the equip scene will be on both hands.
@export var add_equip_scene_to_both_hands := false

## How long you must wait to use the item again.
@export var usage_cooldown := 0.5

func use(player: BogWitch) -> void:
	Player.use_weapon(self)
	if player.alt_hand_for_attack_anim && alt_use_animation != &"":
		player.arms_overlay.arms.play_anim(alt_use_animation, true, use_animation_speed)
	else:
		player.arms_overlay.arms.play_anim(use_animation, true, use_animation_speed)
	_inner_use(player)
	player.alt_hand_for_attack_anim = !player.alt_hand_for_attack_anim

func _inner_use(_player: BogWitch) -> void:
	pass

func can_be_combined(_me: InventoryDetail, _them: InventoryDetail) -> bool:
	return false

func combine(_me: InventoryDetail, _them: InventoryDetail) -> void:
	pass

func is_destroyed_after_merge(_me: InventoryDetail) -> bool:
	return true

func is_ammo_applicable() -> bool:
	return false

func get_item_name(_id: InventoryDetail) -> String:
	return name

func get_description(_id: InventoryDetail) -> String:
	return description

func get_equip_instance() -> Node3D:
	var path := scene_path if custom_equip_scene == "" else custom_equip_scene
	var scene: PackedScene = load(path)
	return scene.instantiate()
