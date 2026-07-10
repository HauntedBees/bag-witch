class_name SpellIcon extends TextureRect

#@onready var _tex: AtlasTexture = texture

func set_spell(s: Weapon) -> void:
	#TODO: add icon
	tooltip_text = s.name
