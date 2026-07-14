class_name SmokeCloud extends Node3D

@export var from_wooden := false

var extreme := false

var _boost_given := false
var _boost_cooldown := 0.0

@onready var _smoke: GPUParticles3D = %Smoke2

func _ready() -> void:
	_smoke.one_shot = true
	_smoke.emitting = true
	if extreme:
		_smoke.amount *= 3
		_smoke.lifetime *= 2.5
	elif from_wooden:
		_smoke.lifetime = 2.0
		_smoke.amount = 20
		_smoke.speed_scale = 0.5

func _process(delta: float) -> void:
	if _boost_cooldown > 0.0:
		_boost_cooldown -= delta
		if _boost_cooldown <= 0.0:
			_boost_given = false

func _on_smoke_2_finished() -> void:
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if _boost_given || from_wooden:
		return
	if body is BogWitch:
		var mult := 3.0 if body.is_on_broom() else 1.0
		body.velocity.y += mult * (5.0 if extreme else 2.0)
		_boost_given = true
		_boost_cooldown = 0.25
