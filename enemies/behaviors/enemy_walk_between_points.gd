class_name EnemyWalkBetweenPoints extends EnemyBehavior

@export var movement_speed := 4.0

@export var delay_range := Vector2(0.0, 1.0)

@export var idle_anims: Array[StringName] = []
@export var run_anims: Array[StringName] = []

var _idle_anim := Anim.IDLE
var _run_anim := Anim.RUN
var _points: Array[Vector3] = []
var _target_point: Vector3
var _delay := 0.0

func _setup_behavior() -> void:
	if idle_anims.size() > 0:
		_idle_anim = idle_anims.pick_random()
	if run_anims.size() > 0:
		_run_anim = run_anims.pick_random()
	_points = _parent.point_collection.get_points()
	_target_point = _points.pick_random()

func _behave(delta: float) -> void:
	var tp := _target_point
	tp.y = _parent.global_position.y
	if _parent.global_position.distance_to(tp) <= 1.0:
		_target_point = _points.pick_random()
		_delay = randf_range(delay_range.x, delay_range.y)
	if _delay > 0.0:
		_parent.animation_player.play(_idle_anim)
		_delay -= delta
		return
	_parent.nav.target_position = _target_point
	var next := _parent.nav.get_next_path_position()
	_parent.velocity = _parent.global_position.direction_to(next) * movement_speed
	if !_parent.is_on_floor():
		_parent.velocity.y -= 5.0
	next.y = _parent.global_position.y
	if _parent.global_position.distance_to(next) > 1.0:
		_parent.look_at(next)
	_parent.move_and_slide()
	_parent.animation_player.play(_run_anim)
