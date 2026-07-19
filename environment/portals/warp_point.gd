class_name WarpPoint extends RayCast3D

@export var velocity_multiplier := 1.0

func _ready() -> void:
	add_to_group(&"warp")
