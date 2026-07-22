class_name ItemTooltip extends MarginContainer

var item: InventoryDetail:
	set(value):
		item = value
		if !is_inside_tree():
			await ready
		_update_item()

@onready var _title: GASLabel = %Title
@onready var _description: GASRichTextLabel = %Description

@onready var _type_icon: TextureRect = %TypeIcon
@onready var _type_icon_tex: AtlasTexture = _type_icon.texture
@onready var _ammo_count: GASLabel = %AmmoCount
@onready var _ammo_icon: TextureRect = %AmmoIcon
@onready var _is_mergeable: TextureRect = %IsMergeable

func _update_item() -> void:
	if item == null:
		return
	_title.text = item.get_item_name()
	_description.text = item.item.get_description(item)
	var i := item.item
	if i.use_animation.is_empty():
		_type_icon_tex.region.position = Vector2(32.0, 32.0)
	else:
		_type_icon_tex.region.position = 16.0 * i.equip_sprite_offset
	if i.is_ammo_applicable() && i is not Ammo:
		_ammo_count.visible = true
		_ammo_icon.visible = true
		_ammo_count.text = str(Player.data.get_remaining_ammo(item))
	else:
		_ammo_count.visible = false
		_ammo_icon.visible = false
	_is_mergeable.visible = true #TODO
	await get_tree().process_frame
	var p := get_parent()
	if p is PopupPanel:
		p.size = Vector2i.ZERO
		p.reset_size()
