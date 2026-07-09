class_name EnemyMeleePlayer extends EnemyBehavior

@export var close_enough_radius: Area3D
@export var attack_frequency := 1.0

var _time_to_next_attack := 0.0
var _is_in_range := false

func _setup_behavior() -> void:
	close_enough_radius.body_entered.connect(_on_player_in_range)
	close_enough_radius.body_exited.connect(_on_player_leave_range)

func _on_player_in_range(body: Node3D) -> void:
	if body is BogWitch:
		_is_in_range = true
		take_control()

func _on_player_leave_range(body: Node3D) -> void:
	if body is BogWitch:
		_is_in_range = false
		_relinquish_control()

func _behave(delta: float) -> void:
	if _parent.target == null || !_is_in_range:
		return
	_time_to_next_attack -= delta
	if _time_to_next_attack <= 0.0:
		_parent.animation_player.play(Anim.SLASH)
		_time_to_next_attack = attack_frequency
