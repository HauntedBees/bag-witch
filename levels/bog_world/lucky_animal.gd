@tool
class_name Malarkey extends Node3D

const _FRAME_TIME := 0.25
const _MULT := 16.0/9.0

@export var texture: Texture2D:
	set(value):
		texture = value
		if !is_inside_tree():
			return
		if texture != null:
			_sprite.texture = texture

## Optional
@export var animated_texture: Texture2D

@export var bounce_peak := 1.0

@onready var _sprite: Sprite3D = %Sprite3D
@onready var _shadow: MeshInstance3D = %Shadow

var _anim_frames := _FRAME_TIME
var _flipped := false

var _bounce_time := 0.0
var _bounce_backwards := false

func _ready() -> void:
	if texture != null:
		_sprite.texture = texture

func _process(delta: float) -> void:
	if _bounce_backwards:
		_bounce_time -= delta
		if _bounce_time <= 0.0:
			_bounce_time = -_bounce_time
			_sprite.flip_h = true
			_bounce_backwards = false
	else:
		_bounce_time += delta
		if _bounce_time >= 1.5:
			_bounce_time = 3.0 - _bounce_time
			_sprite.flip_h = false
			_bounce_backwards = true
	var x := _bounce_time
	var y := (_MULT * -bounce_peak) * x * (x - 1.5)
	_sprite.position = Vector3(x, y, 0.0)
	_shadow.position.x = x
	var shadow_scale := 1.0 - (bounce_peak / 2.0) * (y / bounce_peak)
	_shadow.scale = shadow_scale * Vector3.ONE
	if animated_texture == null:
		return
	_anim_frames -= delta
	if _anim_frames <= 0.0:
		_anim_frames += _FRAME_TIME
		_sprite.texture = texture if _flipped else animated_texture
		_flipped = !_flipped
