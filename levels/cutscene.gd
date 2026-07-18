class_name Cutscene extends Node

@export var required_key: StringName
@export var completed_key: StringName
@export var nodes_to_kill: Array[Node] = []

func _ready() -> void:
	if !required_key.is_empty() && !Player.has_completed(required_key):
		_clean_up()
		queue_free()
		return
	if Player.has_completed(completed_key):
		_clean_up()
		queue_free()
		return
	_init_cutscene()

func _clean_up() -> void:
	for n in nodes_to_kill:
		n.queue_free()
	nodes_to_kill.clear()
	_additional_cleanup()

func _additional_cleanup() -> void:
	pass

func _init_cutscene() -> void:
	pass
