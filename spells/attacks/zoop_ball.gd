class_name ZoopBall extends Projectile

var player: BogWitch

@onready var _body_yadi_yadi_yadi: RigidBody3D = %RigidBody3D

func initialize(w: ProjectileWeapon, attacker_pos: Vector3) -> void:
	_weapon = w
	_source_position = attacker_pos
	var dir := -global_transform.basis.z.normalized()
	if !is_inside_tree():
		await ready
	_body_yadi_yadi_yadi.apply_impulse(dir * 50.0)

func _physics_process(_delta: float) -> void:
	pass

func _on_rigid_body_3d_body_entered(body: Node) -> void:
	player.global_position = _body_yadi_yadi_yadi.global_position
	queue_free()
