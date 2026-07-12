class_name EnemyReceiveDamage extends EnemyBehavior

const _STUN_TIME := 0.2

var _time_stunned := 0.0

func _setup_behavior() -> void:
	priority = _DAMAGED_PRIORITY
	_parent.on_hit.connect(_on_hit)

func _on_hit(w: Weapon, source: Vector3, damage_dealt: int) -> void:
	if !active:
		return
	take_control()
	_time_stunned = _STUN_TIME
	if w.knockback > 0.0:
		var dir := _parent.global_position.direction_to(source)
		_parent.velocity -= dir.normalized() * w.knockback
		_parent.velocity.y += w.additional_y_knockback
	if _parent.is_dead(): # can still knock around a dead body but it won't look at you
		return
	_parent.animation_player.play(
		Anim.BIG_HIT \
		if damage_dealt >= (_parent.max_health * 0.1) || _parent.is_in_danger() \
		else Anim.HIT,
		-1,
		2.0
	)
	var received_direction := source
	received_direction.y = _parent.global_position.y
	_parent.look_at(received_direction)

func _behave(delta: float) -> void:
	if _time_stunned <= 0.0:
		return
	_time_stunned -= delta
	if _time_stunned <= 0:
		_relinquish_control()
