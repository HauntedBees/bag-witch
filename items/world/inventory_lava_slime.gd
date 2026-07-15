extends Node3D

@onready var _anim: AnimationPlayer = $lava_slime/AnimationPlayer

func _ready() -> void:
	_anim.play("ROAM")
	_anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished(_name: StringName) -> void:
	_anim.play("ROAM")
