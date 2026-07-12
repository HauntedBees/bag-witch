class_name SmokeCloud extends Node3D

var extreme := false

@onready var _smoke: GPUParticles3D = %Smoke2

func _ready() -> void:
	_smoke.one_shot = true
	_smoke.emitting = true
	if extreme:
		_smoke.amount *= 3
		_smoke.lifetime *= 2.0

func _on_smoke_2_finished() -> void:
	queue_free()
