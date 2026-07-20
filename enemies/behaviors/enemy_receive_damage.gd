class_name EnemyReceiveDamage extends EnemyBehavior

const _OUCHIE := preload("uid://ni2oyb1sktk0")

var _time_stunned := 0.0
var _hit_anim: StringName
var _big_hit_anim: StringName
var _stun_time: float

func _init(stun_time: float, weak_hit_anim: StringName, strong_hit_anim: StringName) -> void:
	_stun_time = stun_time
	_hit_anim = weak_hit_anim
	_big_hit_anim = strong_hit_anim

func _setup_behavior() -> void:
	priority = _DAMAGED_PRIORITY
	_parent.on_hit.connect(_on_hit)

func _on_hit(w: Weapon, source: Vector3, damage_dealt: int, impact_position: Vector3) -> void:
	var freezes := _stun_time > 0.0 && !w.no_stun
	if !active:
		return
	if freezes:
		take_control()
		_time_stunned = _stun_time
	if w.knockback > 0.0:
		var dir := _parent.global_position.direction_to(source)
		_parent.velocity -= dir.normalized() * w.knockback
		_parent.velocity.y += w.additional_y_knockback
	if _parent.is_dead(): # can still knock around a dead body but it won't look at you
		return
	var ouch: HitParticle = _OUCHIE.instantiate()
	ouch.set_damage(damage_dealt, _parent.is_about_to_die(damage_dealt))
	_parent.add_child(ouch)
	ouch.global_position = impact_position
	if freezes:
		_parent.animation_player.play(
			_big_hit_anim \
			if damage_dealt >= (_parent.max_health * 0.1) || _parent.is_in_danger() \
			else _hit_anim,
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
