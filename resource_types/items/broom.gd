class_name Broom extends Weapon

const _SWIPE_ATTACK := preload("uid://4203p30iy6tv")

func _inner_use(player: BogWitch) -> void:
	player.arms_overlay.arms.play_anim(&"BroomSwing1")
	var swipe: PlayerAttack = _SWIPE_ATTACK.instantiate()
	swipe.weapon = self
	player.add_child(swipe)
