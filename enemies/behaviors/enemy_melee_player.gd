class_name EnemyMeleePlayer extends EnemyBehavior

@export var attack_anims: Array[StringName] = []
@export var close_enough_radius: Area3D
@export var attack_frequency := 1.0
@export var attack_y_offset := 0.5
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var attack_scene: String

var _time_to_next_attack := 0.0
var _is_in_range := false
var _cached_attack_scene: PackedScene = null
var _in_animation := false

func _setup_behavior() -> void:
	if attack_anims.size() == 0:
		attack_anims.append(Anim.SLASH)
	close_enough_radius.body_entered.connect(_on_player_in_range)
	close_enough_radius.body_exited.connect(_on_player_leave_range)

func _on_player_in_range(body: Node3D) -> void:
	if body is BogWitch:
		_is_in_range = true
		take_control()

func _on_player_leave_range(body: Node3D) -> void:
	if body is BogWitch:
		_is_in_range = false
		if !_in_animation:
			_relinquish_control()

func _behave(delta: float) -> void:
	if _parent.target == null || !_is_in_range:
		return
	_time_to_next_attack -= delta
	if _time_to_next_attack <= 0.0:
		if _cached_attack_scene == null:
			_cached_attack_scene = load(attack_scene)
		var attack: EnemyAttack = _cached_attack_scene.instantiate()
		attack.knockback_source = _parent.global_position
		_parent.look_at(_get_look_pos())
		_parent.add_child(attack)
		attack.position.y += attack_y_offset
		_in_animation = true
		_parent.animation_player.play(attack_anims.pick_random(), -1.0, 2.5)
		_parent.animation_player.animation_finished.connect(_on_anim_finished, CONNECT_ONE_SHOT)
		_time_to_next_attack = attack_frequency

func _get_look_pos() -> Vector3:
	var p := _parent.target.global_position
	p.y = _parent.global_position.y
	return p

func _on_anim_finished(_anim: StringName) -> void:
	_in_animation = false
	if !_is_in_range:
		_time_to_next_attack = 0.0
		_relinquish_control()
