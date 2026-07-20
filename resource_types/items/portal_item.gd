class_name PortalItem extends Item

@export var portal_image: Texture2D
@export var portal_dest_uid: String
@export var portal_dest_point: String

func _init(portal: Portal = null) -> void:
	size = Vector2i(1, 1)
	if portal == null:
		return
	name = "Portal Wisp"
	description = "If I place this wisp, it'll warp me to the portal's original destination."
	type = Item.ItemType.Portal
	icon = Rect2i(0, 6, 1, 1)
	first_get_text = "Woah! I didn't think I'd actually be able to bag one of THESE! This could come in handy."
	portal_image = portal.subviewport.get_texture()
	portal_dest_uid = portal.teleport_scene
	portal_dest_point = portal.teleport_point_name
	equipped_animation = &"WispHold"
	use_animation = &"CreatureOffer"
	use_animation_speed = 9.0
	discard_on_use = true
	scene_path = "uid://dtrdt6myagqjf" # portal_wisp.tscn

func _inner_use(player: BogWitch) -> void:
	await player.get_tree().create_timer(0.125).timeout
	SignalBus.load_new_level.emit(portal_dest_uid, portal_dest_point)
