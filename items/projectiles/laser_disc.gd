extends Projectile

@onready var _rot_axis: Node3D = %RotAxis

func _ready() -> void:
	_rot_axis.rotate_z(randf_range(0.0, TAU))
