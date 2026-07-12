class_name EnemyFrozen extends EnemyBehavior

const _STUN_TIMES: Array[float] = [3.0, 3.5, 5.0]
const _RELEASE_DAMAGES: Array[int] = [25, 30, 40]
const _ICE_SCENE := preload("uid://brjmi7v2y6hgo")

var _damage_remaining := 0
var _time_stunned := 0.0
var _cube: IceCube = null

func _setup_behavior() -> void:
	priority = _DAMAGED_PRIORITY + 1
	_parent.on_effect_applied.connect(_on_effect_applied)
	_parent.on_hit.connect(_on_hit)

func _on_active_changed() -> void:
	_damage_remaining = 0
	_time_stunned = 0
	if !active:
		_kill_cube()

func _on_hit(w: Weapon, source: Vector3, damage_dealt: int) -> void:
	if !active:
		return
	if damage_dealt >= (_parent.max_health * 0.5):
		_relinquish_control()
		_kill_cube()
		var new_damage := roundi(_parent.max_health * 0.25)
		_parent.take_specific_damage(new_damage)
		_parent.on_hit.emit(w, source, new_damage)
	else:
		_damage_remaining -= damage_dealt
		if _damage_remaining <= 0:
			_relinquish_control()
			_kill_cube()

func _on_effect_applied(e: BWEnum.Effect, level: int) -> void:
	if e != BWEnum.Effect.Freeze:
		return
	if _time_stunned > 0.0: # no double freezies
		return
	take_control()
	_time_stunned = _STUN_TIMES[level - 1]
	_damage_remaining = _RELEASE_DAMAGES[level - 1]
	_cube = _ICE_SCENE.instantiate()
	_parent.add_child(_cube)
	_parent.animation_player.pause()
	_cube.global_position = _parent.bounding_box.global_position
	_cube.fit_to_box(_parent.bounding_box.shape)

func _behave(delta: float) -> void:
	if _time_stunned <= 0.0:
		return
	_time_stunned -= delta
	if _time_stunned <= 0:
		_relinquish_control()
		_kill_cube()

func _kill_cube() -> void:
	if _cube != null:
		_cube.queue_free()
		_cube = null
