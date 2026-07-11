class_name EnemyDisplay extends CharacterBody3D

## This should be obvious.
@export var enemy_name := ""

## The enemy's max health and initial health.
@export var max_health := 100

## The nav agent for this enemy.
@onready var nav: NavigationAgent3D = $NavigationAgent3D

## The animation player for this enemy.
@export var animation_player: AnimationPlayer

## For the HUD.
@export var bounding_box: CollisionShape3D

var target: BogWitch
var stunned := false

var _health := 100
var _stun_delay := 0.0
var _effects: Dictionary[BWEnum.Effect, float] = {}

@onready var _box: BoxShape3D = bounding_box.shape

func _ready() -> void:
	_health = max_health
	if animation_player != null:
		animation_player.play(Anim.IDLE)

func _physics_process(delta: float) -> void:
	if stunned:
		_stun_delay -= delta
		if _stun_delay <= 0.0:
			stunned = false
	for e: BWEnum.Effect in _effects.keys():
		_effects[e] -= delta
		if _effects[e] <= 0.0:
			_effects.erase(e)
	# TODO: handle knockback

func get_screen_bounds() -> Rect2:
	return BWEnum.get_bounds(global_transform, _box, get_viewport().get_camera_3d())

func take_damage(amount: int, received_direction := Vector3.ZERO) -> void:
	_health -= amount
	stunned = true
	_stun_delay = 0.25
	animation_player.play(Anim.BIG_HIT if amount >= (max_health * 0.1) || _health <= (0.1 * max_health) else Anim.HIT, -1, 2.0)
	received_direction.y = global_position.y
	look_at(received_direction)

func apply_effect(effect: BWEnum.Effect, amount: float) -> void:
	if _effects.has(effect):
		_effects[effect] += amount
	else:
		_effects[effect] = amount
	_process_effects()

func _process_effects() -> void:
	if _effects.has(BWEnum.Effect.Freeze):
		print("Freezy Breezy: %s" % _effects[BWEnum.Effect.Freeze])
	# TODO: make it mean something
	pass
