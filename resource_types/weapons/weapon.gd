class_name Weapon extends Item

@export var cooldown := 0.5

## If this weapon is a spell.
@export var is_spell := false

## Once you no longer have the spellbook for this spell in your inventory, you'll have this much ammo remaining.
@export var spell_ammo := 5

func use(player: BogWitch) -> void:
	Player.use_weapon(self)
	_inner_use(player)

func _inner_use(_player: BogWitch) -> void:
	pass
