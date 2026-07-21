class_name EnemyMeleePlayer extends EnemyBehavior

const _CLOSE_ENOUGH_AIM_DIR = PI / 4.0

@export var attack_anims: Array[StringName] = []
@export var close_enough_radius: Area3D
@export var attack_frequency := 1.0
@export var attack_y_offset := 0.5
@export var rotation_speed := 4.0
## Makes the attack position vary slightly with each attack, increasing odds of missing.
@export var wiggle_attack := false
@export var damage_range := Vector2i.ZERO
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var attack_scene: String

var _time_to_next_attack := 0.0
var _is_in_range := false
var _cached_attack_scene: PackedScene = null
var _in_animation := false

func _setup_behavior() -> void:
	if attack_anims.size() == 0:
		attack_anims.append(Anim.NewKayKit.SLASH if _parent.is_new_anims else Anim.OldKayKit.SLASH)
	if close_enough_radius is VisionCone3D:
		close_enough_radius.body_sighted.connect(_on_player_in_range)
		close_enough_radius.body_hidden.connect(_on_player_leave_range)
	else:
		close_enough_radius.body_entered.connect(_on_player_in_range)
		close_enough_radius.body_exited.connect(_on_player_leave_range)
	_parent.animation_player.animation_finished.connect(_on_anim_finished)

func _on_player_in_range(body: Node3D) -> void:
	if _parent.is_dead():
		return
	if body is BogWitch:
		_parent.target = body
		_is_in_range = true
		take_control()

func _on_player_leave_range(body: Node3D) -> void:
	if _parent.is_dead():
		return
	if body is BogWitch:
		_is_in_range = false
		if !_in_animation:
			_relinquish_control()

func _behave(delta: float) -> void:
	if _parent.target == null || !_is_in_range:
		return
	_parent.velocity = lerp(
		_parent.velocity,
		Vector3(0.0, _parent.velocity.y, 0.0),
		3.0 * delta
	)
	_time_to_next_attack -= delta
	var my_dir := -_parent.transform.basis.z
	var player_dir := _parent.global_position.direction_to(_parent.target.global_position)
	player_dir.y = 0.0
	var angle_diff := my_dir.angle_to(player_dir)
	if angle_diff >= _CLOSE_ENOUGH_AIM_DIR:
		_parent.rotation.y = lerp_angle(
			_parent.rotation.y,
			atan2(-player_dir.x, -player_dir.z),
			rotation_speed * delta
		)
		return
	if _time_to_next_attack <= 0.0:
		if _cached_attack_scene == null:
			_cached_attack_scene = load(attack_scene)
		var attack: EnemyAttack = _cached_attack_scene.instantiate()
		if damage_range != Vector2i.ZERO:
			attack.damage_range = damage_range
		attack.knockback_source = _parent.global_position
		var target_pos := _get_look_pos()
		_parent.look_at(target_pos)
		if attack is EnemyProjectileAttack:
			_parent.get_parent().get_parent().add_child(attack)
			attack.global_position = _parent.global_position
			attack.look_at(target_pos)
		else:
			_parent.add_child(attack)
		attack.position.y += attack_y_offset
		_in_animation = true
		_parent.animation_player.play(attack_anims.pick_random(), -1.0, 3.0)
		_time_to_next_attack = attack_frequency

func _get_look_pos() -> Vector3:
	var p := _parent.target.global_position
	p.y = _parent.global_position.y
	if wiggle_attack:
		p.x += randf_range(-2.0, 2.0)
		p.z += randf_range(-2.0, 2.0)
	return p

func _on_anim_finished(_anim: StringName) -> void:
	_in_animation = false
	if !_is_in_range:
		_time_to_next_attack = 0.0
		_relinquish_control()
