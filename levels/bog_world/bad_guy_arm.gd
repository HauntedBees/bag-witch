class_name BadGuyArm extends Node3D

signal grabbed()
signal done()

@export var endpoint: Marker3D

@onready var _anim: AnimationPlayer = %AnimationPlayer

func lunge() -> void:
	var t := create_tween()
	var init_pos := global_position
	t.tween_property(self, "global_position", endpoint.global_position, 0.25)
	t.tween_callback(_on_lunged)
	t.tween_interval(0.5)
	t.tween_property(self, "global_position", init_pos, 0.5)
	t.tween_callback(_on_done)

func _on_lunged() -> void:
	_anim.play("Grab")
	grabbed.emit()

func _on_done() -> void:
	done.emit()
