class_name SmackAttack extends Weapon

const _SMACK_ATTACK := preload("uid://clws3ydptj3xx")

func _inner_use(player: BogWitch) -> void:
	var swipe: PlayerAttack = _SMACK_ATTACK.instantiate()
	swipe.weapon = self
	player.add_child(swipe)
	var pos := player.get_mouse_center()
	pos.y = swipe.global_position.y
	swipe.look_at(pos)
