class_name EnemyChasePlayer extends EnemyBehavior

@export var vision: Area3D
@export var movement_speed := 5.0
@export var give_up_time := 10.0

@export var idle_anims: Array[StringName] = []
@export var run_anims: Array[StringName] = []

var _can_see_player := false
var _time_to_give_up := 0.0

var _idle_anim := Anim.IDLE
var _run_anim := Anim.RUN

func _setup_behavior() -> void:
	_parent.on_target_identified.connect(_on_target_identified_from_another_source)
	if idle_anims.size() > 0:
		_idle_anim = idle_anims.pick_random()
	if run_anims.size() > 0:
		_run_anim = run_anims.pick_random()
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
	if _parent.is_dead():
		return
	if body is BogWitch:
		_can_see_player = true
		_parent.target = body
		_parent.nav.target_position = NavigationServer3D.map_get_closest_point(
			_parent.nav.get_navigation_map(),
			_parent.target.global_position
		)
		take_control()

func _on_player_lost(body: Node3D) -> void:
	if _parent.is_dead():
		return
	if body is BogWitch:
		_can_see_player = false
		_time_to_give_up = give_up_time

func _on_target_identified_from_another_source() -> void:
	if _parent.is_dead():
		return
	_time_to_give_up = give_up_time * 1.5
	_parent.animation_player.play(_run_anim)

func _behave(delta: float) -> void:
	if _parent.target == null:
		return
	if !_can_see_player:
		_time_to_give_up -= delta
		if _time_to_give_up <= 0.0:
			_relinquish_control()
			_parent.target = null
			_parent.animation_player.play(_idle_anim)
			return
	# none of this shit fucking works, why. why.
	# it reduces the errors from thousands to a dozen, but WHY.
	if _parent.nav.is_navigation_finished() || !_parent.nav.is_target_reachable():
		_can_see_player = false
		return
	_parent.nav.target_position = NavigationServer3D.map_get_closest_point(
		_parent.nav.get_navigation_map(),
		_parent.target.global_position
	)
	if _parent.nav.is_navigation_finished() || !_parent.nav.is_target_reachable():
		_can_see_player = false
		return
	var next := _parent.nav.get_next_path_position()
	_parent.velocity = _parent.global_position.direction_to(next) * movement_speed
	next.y = _parent.global_position.y
	if _parent.global_position.distance_to(next) > 1.0:
		_parent.look_at(next)
	_parent.animation_player.play(_run_anim)
