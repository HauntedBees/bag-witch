class_name JumpSpell extends Spell

@export var y_velocity := 0.0
@export var duration := 0.0

func _inner_use(player: BogWitch) -> void:
	player.velocity.y = y_velocity
	player.add_clinging_effect(JumpEffect.new(player, y_velocity, duration))
