class_name Projectile extends Node3D

@export var effect := BWEnum.Effect.None

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
	var body_parent := body.get_parent()
	if body is EnemyDisplay:
		var space_state := get_world_3d().direct_space_state
		var dir := -global_transform.basis.z.normalized()
		var query := PhysicsRayQueryParameters3D.create(global_position - dir * 2.0, global_position + dir * 100.0)
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			body.receive_weapon_hit(_source_position, _weapon)
		else:
			body.receive_weapon_hit(_source_position, _weapon, true, result["position"])
	elif body_parent != null && body_parent is Waterfall:
		var wf := body_parent as Waterfall
		if effect == BWEnum.Effect.Burn && wf.frozen:
			wf.frozen = false # TODO: play a sound
	queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	var area_parent := area.get_parent()
	if area_parent != null && area_parent is Waterfall:
		var wf := area_parent as Waterfall
		if effect == BWEnum.Effect.Freeze && !wf.frozen:
			wf.frozen = true # TODO: play a sound
		queue_free()
