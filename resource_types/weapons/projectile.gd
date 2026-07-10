class_name Projectile extends Node3D

var _weapon: ProjectileWeapon
var _time_remaining := 0.0
var _source_position := Vector3.ZERO

func initialize(w: ProjectileWeapon, attacker_pos: Vector3) -> void:
	_weapon = w
	_time_remaining = w.fade_time
	_source_position = attacker_pos

func _physics_process(delta: float) -> void:
	var dir := -global_transform.basis.z.normalized()
	var velocity := dir * _weapon.velocity * delta
	velocity.y -= _weapon.gravity
	global_position += velocity
	_time_remaining -= delta
	if _time_remaining <= 0.0:
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("hit %s" % body.name)
	if body is EnemyDisplay:
		if _weapon.knockback > 0.0:
			var dir := body.global_position.direction_to(_source_position)
			body.velocity -= dir.normalized() * _weapon.knockback
			body.velocity.y += _weapon.additional_y_knockback
		body.take_damage(randi_range(_weapon.damage_range.x, _weapon.damage_range.y), _source_position)
		for e: BWEnum.Effect in _weapon.metadata_increase_ranges.keys():
			var r := _weapon.metadata_increase_ranges[e]
			body.apply_effect(e, randf_range(r.x, r.y))
	queue_free()
