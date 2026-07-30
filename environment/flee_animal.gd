@tool
class_name FleeAnimal extends RigidBody3D

const _TEX_SIZE := 16.0
const _FRAME_TIME := 0.25
const _MULT := 16.0/9.0
const _TEXTURES: Array[Vector2] = [
	Vector2(0.0, 0.0), # Owl
	Vector2(2.0, 0.0), # Falcon?
	Vector2(6.0, 0.0), # Raven
	Vector2(8.0, 0.0), # Bat
	Vector2(6.0, 1.0), # Lizard
	Vector2(7.0, 1.0), # Frog
	Vector2(9.0, 1.0), # Turtle
	Vector2(2.0, 2.0), # Goat
	Vector2(3.0, 2.0), # Sheep
	Vector2(1.0, 3.0), # Deer
	Vector2(3.0, 3.0), # Bear
	Vector2(9.0, 3.0), # Fox
	Vector2(5.0, 4.0), # Sqorl
	Vector2(6.0, 4.0), # Ferret?
	Vector2(7.0, 4.0), # Rabbit
	Vector2(8.0, 4.0), # Jimothy
	Vector2(9.0, 4.0), # Badger
]
const _ANIMATED_TEXTURES: Array[Vector2] = [
	Vector2(0.0, 0.0),
	Vector2(2.0, 0.0),
	Vector2(6.0, 0.0),
	Vector2(8.0, 0.0),
]

var _base_offset := Vector2.ZERO
var _bounce_peak := 1.0
var _bounce_speed := 1.0
var _bounce_time := 0.0

var _anim_offset := Vector2.LEFT
var _anim_frames := _FRAME_TIME
var _anim_flipped := false
var _time_to_live := 10.0
var _desired_velocity := Vector2.ZERO

@onready var _sprite: Sprite3D = %Sprite3D
@onready var _sprite_tex: AtlasTexture = _sprite.texture
@onready var _shadow: MeshInstance3D = %Shadow

func _ready() -> void:
	_base_offset = _TEXTURES.pick_random()
	if _ANIMATED_TEXTURES.has(_base_offset):
		_anim_offset = _base_offset + Vector2.RIGHT
	_sprite_tex.region.position = _TEX_SIZE * _base_offset
	_bounce_peak = randf_range(0.5, 3.0)
	_bounce_speed = randf_range(2.0, 4.0)
	_desired_velocity = Vector2(
		(2.0 if randf() < 0.5 else -2.0) * randf_range(0.25, 1.0),
		(2.0 if randf() < 0.5 else -2.0) * randf_range(0.25, 1.0)
	)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var vel := state.linear_velocity
	vel.x = _desired_velocity.x
	vel.z = _desired_velocity.y
	state.linear_velocity = vel

func _process(delta: float) -> void:
	_time_to_live -= delta
	if _time_to_live <= 0.0:
		queue_free()
		return
	_bounce_time += _bounce_speed * delta
	var y := _bounce_peak * absf(sin(_bounce_time))
	_sprite.position = Vector3(0.0, y + 0.35, 0.0)
	var shadow_scale := 1.0 - (_bounce_peak / 2.0) * (y / _bounce_peak)
	_shadow.scale = shadow_scale * Vector3.ONE
	if _anim_offset.x < 0:
		return
	_anim_frames -= delta
	if _anim_frames <= 0.0:
		_anim_frames += _FRAME_TIME
		_anim_flipped = !_anim_flipped
		_sprite_tex.region.position = _TEX_SIZE * (_anim_offset if _anim_flipped else _base_offset)
