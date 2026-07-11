class_name EnemyDisplay extends CharacterBody3D

signal on_died()
signal on_hit(w: Weapon, dir: Vector3, damage_dealt: int)

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

var _health := 100
var _effects: Dictionary[BWEnum.Effect, float] = {}

@onready var _box: BoxShape3D = bounding_box.shape

func _ready() -> void:
	add_child(EnemyReceiveDamage.new())
	add_child(EnemyDead.new())
	_health = max_health
	if animation_player != null:
		animation_player.play(Anim.IDLE)

func is_in_danger() -> bool:
	return _health <= (0.1 * max_health)

func is_dead() -> bool:
	return _health <= 0

func _physics_process(delta: float) -> void:
	for e: BWEnum.Effect in _effects.keys():
		_effects[e] -= delta
		if _effects[e] <= 0.0:
			_effects.erase(e)
	# TODO: handle knockback

func receive_weapon_hit(source: Vector3, w: Weapon) -> void:
	var damage_dealt := randi_range(w.damage_range.x, w.damage_range.y)
	on_hit.emit(w, source, damage_dealt)
	if _health <= 0:
		return
	_health -= damage_dealt
	for e: BWEnum.Effect in w.metadata_increase_ranges.keys():
		var r := w.metadata_increase_ranges[e]
		apply_effect(e, randf_range(r.x, r.y))
	if _health <= 0:
		on_died.emit()

func get_screen_bounds() -> Rect2:
	return BWEnum.get_bounds(global_transform, _box, get_viewport().get_camera_3d())

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
