class_name Cutscene extends Node

@export var completed_key: StringName
@export var nodes_to_kill: Array[Node] = []

func _ready() -> void:
	if Player.has_completed(completed_key):
		_clean_up()
		queue_free()
		return
	_init_cutscene()

func _clean_up() -> void:
	for n in nodes_to_kill:
		n.queue_free()
	nodes_to_kill.clear()

func _init_cutscene() -> void:
	pass
