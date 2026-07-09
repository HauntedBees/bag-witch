class_name EnemyChasePlayer extends EnemyBehavior

@export var vision: Area3D

func _setup_behavior() -> void:
	if vision is VisionCone3D:
		vision.body_sighted.connect(_on_player_sighted)
	else:
		vision.body_entered.connect(_on_player_sighted)

func _on_player_sighted(body: Node3D) -> void:
	if body is BogWitch:
		_parent.target = body

func _behave(_delta: float) -> void:
	if _parent.target == null:
		return
	_parent.nav.target_position = _parent.target.global_position
	var next := _parent.nav.get_next_path_position()
	_parent.velocity = _parent.global_position.direction_to(next) * _parent.movement_speed
	_parent.look_at(next)
	_parent.move_and_slide()
