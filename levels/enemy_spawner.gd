class_name EnemySpawner extends Node3D

const _SKELETON_KEY := preload("uid://do1jwf5icgroo")

@export var dont_spawn_if_quest_is_not_met: StringName

@export var enemy_types: Array[PackedScene] = []
@export var potential_spawn_points: PointCollection3D
@export var spawn_point_offset := Vector3(0.0, 1.0, 0.0)
@export var enemy_point_collection: Path3D
@export var spawn_container: Node3D
@export var max_spawned := 6
@export var time_between_spawn_attempts := 30.0
@export var spawn_chance := 0.8
@export var include_skeleton_keys := false

var _points: Array[Vector3]
var _time_to_next_spawn_check := 0.0
var _last_spawn_point := Vector3.ZERO

func _ready() -> void:
	if !dont_spawn_if_quest_is_not_met.is_empty() && !Player.has_completed(dont_spawn_if_quest_is_not_met):
		visible = false
		return
	_points = potential_spawn_points.get_points()
	if !visible:
		return
	var remaining_to_spawn := max_spawned - _get_enemy_count()
	while remaining_to_spawn > 0:
		_spawn_enemy()
		remaining_to_spawn -= 1

func _process(delta: float) -> void:
	if !visible:
		return
	if _get_enemy_count() >= max_spawned:
		return
	_time_to_next_spawn_check -= delta
	if _time_to_next_spawn_check <= 0.0:
		if randf() <= spawn_chance:
			_spawn_enemy()
		_time_to_next_spawn_check = time_between_spawn_attempts

func _spawn_enemy() -> void:
	var enemy_scene: PackedScene = _pick_enemy()
	var enemy: EnemyDisplay = enemy_scene.instantiate()
	enemy.name = "%s%s" % [enemy.enemy_name, randi()]
	if include_skeleton_keys:
		enemy.potential_drops.append(_SKELETON_KEY)
		enemy.potential_drops.append(_SKELETON_KEY)
		enemy.potential_drops.append(_SKELETON_KEY)
		enemy.potential_drops.append(_SKELETON_KEY)
	if enemy_point_collection != null:
		enemy.point_collection = enemy_point_collection
	spawn_container.add_child(enemy)
	var point := _last_spawn_point
	while point == _last_spawn_point:
		point = _points.pick_random()
	_last_spawn_point = point
	enemy.global_position = point + spawn_point_offset + Vector3(
		randf_range(-2.0, 2.0),
		0.0,
		randf_range(-2.0, 2.0)
	)
	enemy.rotate_y(randf_range(-PI, PI))

func _pick_enemy() -> PackedScene:
	return enemy_types.pick_random()

func _get_enemy_count() -> int:
	var count := 0
	for e: EnemyDisplay in spawn_container.get_children():
		if !e.is_dead():
			count += 1
	return count
