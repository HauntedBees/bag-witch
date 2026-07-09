class_name Projectile extends Node3D

var _weapon: ProjectileWeapon
var _time_remaining := 0.0

func initialize(w: ProjectileWeapon) -> void:
	_weapon = w
	_time_remaining = w.fade_time

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
	# TODO: enemies
	queue_free()
