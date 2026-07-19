class_name Cutscene extends Node

## If null, this cutscene is triggered immediately. Otherwise, triggered
## when the player enters this area.
@export var trigger_area: Area3D

@export var required_key: StringName
@export var completed_key: StringName
@export var nodes_to_kill: Array[Node] = []

var _triggered := false

func _ready() -> void:
	if !required_key.is_empty() && !Player.has_completed(required_key):
		_clean_up()
		queue_free()
		return
	if Player.has_completed(completed_key):
		_clean_up()
		queue_free()
		return
	if trigger_area == null:
		_init_cutscene()
		_triggered = true
	else:
		trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if _triggered:
		return
	if body is BogWitch:
		_triggered = true
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
