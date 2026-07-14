extends Projectile

const _SMOKE_SCENE := preload("uid://bce761tpdiksy")

@onready var _shape_cast: ShapeCast3D = %ShapeCast3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"snow"):
		_add_smoke(body, false)
	elif body.is_in_group(&"ice"):
		_add_smoke(body, true)
	super(body)

func _add_smoke(body: Node3D, extreme: bool) -> void:
	var smoke: SmokeCloud = _SMOKE_SCENE.instantiate()
	smoke.extreme = extreme
	body.add_child(smoke)
	_shape_cast.force_shapecast_update()
	if _shape_cast.is_colliding():
		smoke.global_position = _shape_cast.get_collision_point(0)
	else:
		smoke.global_position = global_position
