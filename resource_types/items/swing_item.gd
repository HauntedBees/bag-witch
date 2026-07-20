class_name SwingItem extends Weapon

const _SWIPE_ATTACK := preload("uid://4203p30iy6tv")

@export var swing_animation_speed := 1.0

func _inner_use(player: BogWitch) -> void:
	var swipe: PlayerAttack = _SWIPE_ATTACK.instantiate()
	swipe.weapon = self
	player.add_child(swipe)
	var pos := player.get_mouse_center()
	pos.y = swipe.global_position.y
	swipe.look_at(pos)
