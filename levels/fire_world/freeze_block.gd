extends Node3D

var sink_speed := 1.0

func _process(delta: float) -> void:
	global_position.y -= delta * sink_speed
