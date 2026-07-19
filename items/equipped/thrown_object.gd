class_name ThrownObject extends RigidBody3D

const _BOOM_SCENE := preload("uid://cv0nw6usfoc80")

var weapon: Throwable

var _ground_hits_til_impact := 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is EnemyDisplay || body is BogWitch:
		_asplode()
	else:
		_ground_hits_til_impact -= 1
		# 30% chance it won't explode on first hit
		if _ground_hits_til_impact < 0 || (_ground_hits_til_impact == 0 && randf() <= 0.3):
			_asplode()

func _asplode() -> void:
	if weapon.explodes_on_impact:
		var boom: Explosion = _BOOM_SCENE.instantiate()
		get_parent().add_child(boom)
		boom.weapon = weapon
		boom.global_position = global_position
		queue_free()
