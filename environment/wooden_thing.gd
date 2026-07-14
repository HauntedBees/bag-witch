class_name WoodenThing extends Node3D

@export var unburnt_state: Node3D
@export var burnt_state: Node3D
@export var fire: Node3D
@export var smoke: Node3D

var _burnt := false

func _ready() -> void:
	_update_burnt_status()

func _update_burnt_status() -> void:
	unburnt_state.visible = !_burnt
	burnt_state.visible = _burnt
	smoke.visible = _burnt

func burn() -> void:
	if _burnt:
		return
	_burnt = true
	fire.visible = true
	await get_tree().create_timer(3.0).timeout
	fire.queue_free()
	_update_burnt_status()
