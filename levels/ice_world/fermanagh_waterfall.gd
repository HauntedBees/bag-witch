@tool
class_name Waterfall extends Node3D

const _FROZEN_SHADER: Material = preload("uid://cx0gck7r7hbl3")
const _REGULAR_SHADER: Material = preload("uid://dsgjuot0c2n6e")
const _FLICKER_TIME := 0.1

@export var frozen := true:
	set(value):
		frozen = value
		_update_frozen()

@onready var _base: MeshInstance3D = $waterfall_base/falls_layer_0
@onready var _collider: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var _falls_break_top_a: MeshInstance3D = $waterfall_base/falls_break_top_a
@onready var _falls_break_bottom_a: MeshInstance3D = $waterfall_base/falls_break_bottom_a
@onready var _falls_break_top_b: MeshInstance3D = $waterfall_base/falls_break_top_b
@onready var _falls_break_bottom_b: MeshInstance3D = $waterfall_base/falls_break_bottom_b
@onready var _hidden_when_frozen: Array[MeshInstance3D] = [
	_falls_break_top_a, _falls_break_top_b, _falls_break_bottom_a, _falls_break_bottom_b
]

var _ticker := 0.0

func _process(delta: float) -> void:
	if frozen:
		return
	_ticker += delta
	if _ticker >= _FLICKER_TIME:
		_ticker -= _FLICKER_TIME
		_falls_break_bottom_b.visible = !_falls_break_bottom_b.visible
		_falls_break_bottom_a.visible = !_falls_break_bottom_b.visible
		_falls_break_top_b.visible = !_falls_break_top_b.visible
		_falls_break_top_a.visible = !_falls_break_top_b.visible

func _update_frozen() -> void:
	if !is_inside_tree():
		await ready
	for c in _hidden_when_frozen:
		c.visible = !frozen
	_base.set_surface_override_material(0, _FROZEN_SHADER if frozen else _REGULAR_SHADER)
	_collider.disabled = !frozen
