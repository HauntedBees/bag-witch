class_name EnemySpawner extends Node3D

@export var enemy_types: Array[PackedScene] = []
@export var potential_spawn_points: PointCollection3D
@export var spawn_point_offset := Vector3(0.0, 1.0, 0.0)
@export var enemy_point_collection: Path3D
@export var spawn_container: Node3D
@export var max_spawned := 6
@export var time_between_spawn_attempts := 30.0
@export var spawn_chance := 0.8

var _points: Array[Vector3]
var _time_to_next_spawn_check := 0.0

func _ready() -> void:
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
	var enemy_scene: PackedScene = enemy_types.pick_random()
	var enemy: EnemyDisplay = enemy_scene.instantiate()
	if enemy_point_collection != null:
		enemy.point_collection = enemy_point_collection
	spawn_container.add_child(enemy)
	enemy.global_position = _points.pick_random() + spawn_point_offset

func _get_enemy_count() -> int:
	var count := 0
	for e: EnemyDisplay in spawn_container.get_children():
		if !e.is_dead():
			count += 1
	return count
