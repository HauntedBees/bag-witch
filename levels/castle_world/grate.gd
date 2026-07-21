class_name Grate extends Node3D

@onready var _grate: MeshInstance3D = $grate2/grate
@onready var _grate_mat: StandardMaterial3D = _grate.get_surface_override_material(0)
@onready var _grate_body: StaticBody3D = %GrateBody

var _health := 100

func receive_hit(damage: int) -> void:
	if _health <= 0:
		return
	_health -= damage
	_grate_mat.albedo_color = Color.DARK_GRAY.lerp(Color.DARK_RED, (100 - _health) / 100.0)
	if _health <= 0:
		_grate_body.queue_free()
		_grate.queue_free()
