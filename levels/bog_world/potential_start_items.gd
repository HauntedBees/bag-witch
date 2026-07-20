extends Node3D

@export var always_potential_items: Array[Item] = []
@export var potential_items_gen_mid: Array[Item] = []
@export var potential_items_gen_late: Array[Item] = []

@export var marker1: Marker3D
@export var marker2: Marker3D

func _ready() -> void:
	# so it doesn't call during opening
	await get_tree().process_frame
	_add_some_items.call_deferred()

func _add_some_items() -> void:
	var potential_items: Array[Item] = []
	potential_items.append_array(always_potential_items)
	if Player.data.generations_elapsed >= BWEnum.GEN_MID:
		potential_items.append_array(potential_items_gen_mid)
	if Player.data.generations_elapsed >= BWEnum.GEN_LATE:
		potential_items.append_array(potential_items_gen_late)
	if randf() <= 0.4:
		_add_item(marker1, potential_items)
	if randf() <= 0.4:
		_add_item(marker2, potential_items)

func _add_item(m: Marker3D, potential_items: Array[Item]) -> void:
	var item: Item = potential_items.pick_random()
	var wi := item.get_world_item()
	m.add_child(wi)
