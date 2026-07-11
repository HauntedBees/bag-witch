class_name SpellIcon extends MarginContainer

var spell: Weapon:
	set(value):
		spell = value
		_update_spell()

#@onready var _icon: TextureRect = %Icon
@onready var _equip_slot: InputImage = %EquipSlot

#@onready var _tex: AtlasTexture = texture

func _ready() -> void:
	_equip_slot.visible = false

func clear_slot() -> void:
	_equip_slot.visible = false

func set_slot(action_name: StringName) -> void:
	_equip_slot.visible = true
	_equip_slot.action_name = action_name

func _update_spell() -> void:
	#TODO: add icon
	tooltip_text = spell.name
