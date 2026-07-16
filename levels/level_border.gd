extends Area3D

func _ready() -> void:
	body_exited.connect(_on_body_exited)

func _on_body_exited(b: Node3D) -> void:
	if b is BogWitch:
		b.global_position = Vector3(
			-b.global_position.x,
			b.global_position.y,
			-b.global_position.z
		)
