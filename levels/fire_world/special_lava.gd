extends CollisionShape3D

func _ready() -> void:
	Player.data.potion_added.connect(_on_potion_changed)
	Player.data.potion_removed.connect(_on_potion_changed)
	_on_potion_changed(null)

func _on_potion_changed(_p: Potion) -> void:
	disabled = !Player.data.has_potion_ability(Potion.Ability.LavaInfusion)
