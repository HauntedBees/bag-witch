class_name GenerationalItemSpawner extends Node

@export var regen_time := -1.0

@export var dont_spawn_if_quest_is_not_met: StringName

@export var potential_spawn_points: PointCollection3D
@export var spawn_point_offset := Vector3(0.0, 1.0, 0.0)
@export var spawn_amount_range := Vector2i(5, 10)

@export_custom(SRP_HINT.RESOURCE_PATH, "Item") var always_items: Array[String] = [
	"uid://dkq75or5ap7mf",
	"uid://7u7qquf88cla",
	"uid://cjykdl4q3h120"
]
@export_custom(SRP_HINT.RESOURCE_PATH, "Item") var rare_always_items: Array[String] = [
	"uid://dpgrb2fqcl3qn",
	"uid://b2ckj75uwnit2",
	"uid://b2ckj75uwnit2",
	"uid://b2ckj75uwnit2",
	"uid://csnhgb33a82l1"
]
@export_custom(SRP_HINT.RESOURCE_PATH, "Item") var mid_gen_items: Array[String] = [
	"uid://dmxepru323w7a",
	"uid://2lbwkp6ohqoq",
	"uid://et3im2qvxysa",
	"uid://d0go325edul0h",
	"uid://d0go325edul0h",
	"uid://d0go325edul0h",
	"uid://8cw7tywrtk5y",
	"uid://8cw7tywrtk5y"
]
@export_custom(SRP_HINT.RESOURCE_PATH, "Item") var rare_mid_gen_items: Array[String] = [
	"uid://bjf5fkot1fjp5",
	"uid://dwy2t5iqcrs8k"
]
@export_custom(SRP_HINT.RESOURCE_PATH, "Item") var late_gen_items: Array[String] = [
	"uid://b2ckj75uwnit2",
	"uid://b2ckj75uwnit2",
	"uid://bblwxtkau8lot",
	"uid://bblwxtkau8lot",
	"uid://w0thup23ageh"
]
@export_custom(SRP_HINT.RESOURCE_PATH, "Item") var rare_late_gen_items: Array[String] = [
	"uid://mbu0okiovudq",
	"uid://drbkhbnqy2d58",
	"uid://cbalo40kwro1e",
	"uid://dg7n54458bcvk",
	"uid://d0ybewc2hbwkv"
]

var _points: Array[Vector3]
var _regen_time := 0.0

var _items: Array[String] = []
var _rares: Array[String] = []
var _cache: Dictionary[String, Item] = {}

func _ready() -> void:
	if !dont_spawn_if_quest_is_not_met.is_empty() && !Player.has_completed(dont_spawn_if_quest_is_not_met):
		queue_free()
		return
	_points = potential_spawn_points.get_points()
	_items = _get_potential_types()
	_rares = _get_potential_rare_types()
	var remaining_to_spawn := randi_range(spawn_amount_range.x, spawn_amount_range.y)
	while remaining_to_spawn > 0 && _points.size() > 0:
		_spawn_item()
		remaining_to_spawn -= 1

func _process(delta: float) -> void:
	if regen_time <= 0.0:
		return
	_regen_time -= delta
	if _regen_time <= 0.0:
		_regen_time = regen_time
		if _points.is_empty():
			_points = potential_spawn_points.get_points()
		_spawn_item()

func _spawn_item() -> void:
	var item: String = ""
	if _rares.size() > 0 && randf() <= 0.1:
		item = _rares.pick_random()
	else:
		item = _items.pick_random()
	if item.is_empty():
		return
	if !_cache.has(item):
		_cache[item] = load(item)
	var wi := _cache[item].get_world_item()
	var p: Vector3 = _points.pick_random()
	_points.erase(p)
	await get_tree().process_frame
	get_parent().add_child(wi)
	wi.global_position = p + spawn_point_offset + Vector3(
		randf_range(-2.0, 2.0),
		0.0,
		randf_range(-2.0, 2.0)
	)

func _get_potential_types() -> Array[String]:
	var potential_items: Array[String] = []
	potential_items.append_array(rare_always_items)
	if Player.data.generations_elapsed >= BWEnum.GEN_MID:
		potential_items.append_array(rare_mid_gen_items)
		if Player.data.generations_elapsed >= BWEnum.GEN_LATE:
			potential_items.append_array(rare_late_gen_items)
	return potential_items

func _get_potential_rare_types() -> Array[String]:
	var potential_items: Array[String] = []
	potential_items.append_array(always_items)
	if Player.data.generations_elapsed >= BWEnum.GEN_MID:
		potential_items.append_array(mid_gen_items)
		if Player.data.generations_elapsed >= BWEnum.GEN_LATE:
			potential_items.append_array(late_gen_items)
	return potential_items
