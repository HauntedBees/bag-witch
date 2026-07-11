class_name SpellIcon extends MarginContainer

const _ATLAS_SIZE := 16.0

var spell: Weapon:
	set(value):
		spell = value
		_update_spell()

@onready var _icon: TextureRect = %Icon
@onready var _equip_slot: InputImage = %EquipSlot

@onready var _tex: AtlasTexture = _icon.texture

func _ready() -> void:
	_equip_slot.visible = false

func clear_slot() -> void:
	_equip_slot.visible = false

func set_slot(action_name: StringName) -> void:
	_equip_slot.visible = true
	_equip_slot.action_name = action_name

func _update_spell() -> void:
	_tex.region.position = _ATLAS_SIZE * spell.equip_sprite_offset
	tooltip_text = spell.name
