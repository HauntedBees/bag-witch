class_name EnemyMeleePlayer extends EnemyBehavior

@export var close_enough_radius: Area3D

func _setup_behavior() -> void:
	close_enough_radius.body_entered.connect(_on_player_in_range)
	close_enough_radius.body_exited.connect(_on_player_leave_range)

func _on_player_in_range(body: Node3D) -> void:
	if body is BogWitch:
		print("FUCK")

func _on_player_leave_range(body: Node3D) -> void:
	if body is BogWitch:
		print("SHIT")
