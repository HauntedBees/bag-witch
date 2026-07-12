class_name EnemyChasePlayer extends EnemyBehavior

@export var vision: Area3D
@export var movement_speed := 5.0
@export var give_up_time := 10.0

var _can_see_player := false
var _time_to_give_up := 0.0

func _setup_behavior() -> void:
	_parent.on_effect_applied.connect(_on_effect_applied)
	if vision is VisionCone3D:
		vision.body_sighted.connect(_on_player_sighted)
		vision.body_hidden.connect(_on_player_lost)
	else:
		vision.body_entered.connect(_on_player_sighted)
		vision.body_exited.connect(_on_player_lost)

func _on_effect_applied(e: BWEnum.Effect, _level: int) -> void:
	if e != BWEnum.Effect.Freeze:
		return
	_time_to_give_up = 0.0

func _on_player_sighted(body: Node3D) -> void:
	if body is BogWitch:
		_can_see_player = true
		_parent.target = body

func _on_player_lost(body: Node3D) -> void:
	if body is BogWitch:
		_can_see_player = false
		_time_to_give_up = give_up_time

func _behave(delta: float) -> void:
	if _parent.target == null:
		return
	if !_can_see_player:
		_time_to_give_up -= delta
		if _time_to_give_up <= 0.0:
			_parent.target = null
			_parent.animation_player.play(Anim.IDLE)
			return
	_parent.nav.target_position = _parent.target.global_position
	var next := _parent.nav.get_next_path_position()
	_parent.velocity = _parent.global_position.direction_to(next) * movement_speed
	if !_parent.is_on_floor():
		_parent.velocity.y -= 5.0
	_parent.look_at(next)
	_parent.move_and_slide()
	_parent.animation_player.play(Anim.RUN)
