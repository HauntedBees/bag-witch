class_name LavaSlime extends EnemyDisplay

const _SMOKE_SCENE := preload("uid://bce761tpdiksy")
const _MAX_SCALE := 5.0
const _MAX_LAVA_SCALE := 50.0

@export var has_key := false

var _current_scale := 1.0
var _soaked_in_lava := false

func _die() -> void:
	_try_drop()
	set_collision_layer_value(4, false)
	on_died.emit()
	var smoke: SmokeCloud = _SMOKE_SCENE.instantiate()
	smoke.extreme = true
	get_parent().get_parent().add_child(smoke) # parent is usually just a container
	smoke.global_position = global_position
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(self, "scale", Vector3(0.05, 0.05, 0.05), 5.0)
	t.tween_property(self, "rotation_degrees:y", 3600.0, 5.0)
	t.set_parallel(false)
	t.tween_callback(queue_free)

func lava_up() -> void:
	if _soaked_in_lava:
		return
	_soaked_in_lava = true
	var t := create_tween()
	t.tween_property(self, "scale", _MAX_LAVA_SCALE * Vector3.ONE, 3.0)

func take_specific_damage(_damage_dealt: int) -> void:
	return

func receive_weapon_hit(source: Vector3, w: Weapon, has_impact_position := false, impact_position := Vector3.ZERO) -> void:
	var effects := w.metadata_increase_ranges.keys()
	var is_ice_attack := false
	for e: BWEnum.Effect in effects:
		if e == BWEnum.Effect.Freeze:
			is_ice_attack = true
			break
		elif e == BWEnum.Effect.Burn:
			_current_scale = minf(_MAX_SCALE, _current_scale * 1.1)
			scale = _current_scale * Vector3.ONE
			break
	var damage_dealt := 0
	if !is_ice_attack && _is_frozen():
		damage_dealt = randi_range(w.damage_range.x, w.damage_range.y)
	on_hit.emit(w, source, damage_dealt, impact_position if has_impact_position else global_position, false)
	if is_dead():
		return
	_health -= damage_dealt
	var magic_level := 1
	if w is Spell:
		magic_level = w.magic_level_requirement
	for e: BWEnum.Effect in effects:
		if e != BWEnum.Effect.Freeze: # TODO: make water and fire just fizzle off
			continue
		var r := w.metadata_increase_ranges[e]
		apply_effect(e, randf_range(r.x, r.y) * 0.75, magic_level)
	if _health <= 0:
		_die()
