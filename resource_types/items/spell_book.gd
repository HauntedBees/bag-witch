class_name Spellbook extends Item

@export var spells: Array[Spell] = []

func _init() -> void:
	first_get_text = "Finally! A spellbook! These portals mess with me memory, so this should help me remember a spell or two!"
