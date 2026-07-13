class_name EnemyDisplay extends CharacterBody3D

signal on_died()
signal on_target_identified()
signal on_hit(w: Weapon, dir: Vector3, damage_dealt: int, impact_position: Vector3)
signal on_effect_applied(e: BWEnum.Effect, level: int)

## This should be obvious.
@export var enemy_name := ""

## To be passed to an EnemyWalkBetweenPoints behavior if one exists.
@export var point_collection: Path3D

## The enemy's max health and initial health.
@export var max_health := 100

@export var idle_anims: Array[StringName] = [Anim.IDLE]

@export var hit_anim := Anim.HIT

@export var big_hit_anim := Anim.BIG_HIT

@export var die_anims: Array[StringName] = [Anim.DIE]

## How long they flinch for when stunned.
@export var damage_stun_time := 0.2

## The nav agent for this enemy.
@onready var nav: NavigationAgent3D = $NavigationAgent3D

## The animation player for this enemy.
@export var animation_player: AnimationPlayer

## For the HUD.
@export var bounding_box: CollisionShape3D

## Things that hurt them more.
@export var weaknesses: Array[BWEnum.Effect] = []

## Effects taht don't apply to them.
@export var resistances: Array[BWEnum.Effect] = []

var target: BogWitch

var _health := 100
var _effects: Dictionary[BWEnum.Effect, float] = {}
@onready var _common_states: Array[EnemyBehavior] = [
	EnemyReceiveDamage.new(damage_stun_time, hit_anim, big_hit_anim),
	EnemyDead.new(die_anims),
	EnemyFrozen.new()
]

@onready var alive_collider: CollisionShape3D = %CollisionShape3D
@onready var death_collider: CollisionShape3D = %DeathCollisionShape3D
@onready var _box: BoxShape3D = bounding_box.shape

func _ready() -> void:
	add_to_group(&"enemy")
	for c in _common_states:
		add_child(c)
	_health = max_health
	if animation_player != null:
		animation_player.play(idle_anims.pick_random())

func _on_peer_called_for_help(new_target: BogWitch, source_position: Vector3, allowed_radius: float) -> void:
	if global_position.distance_to(source_position) > allowed_radius:
		return
	target = new_target
	on_target_identified.emit()

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

func take_specific_damage(damage_dealt: int) -> void:
	if _health <= 0:
		return
	_health -= damage_dealt
	if _health <= 0:
		on_died.emit()

func receive_weapon_hit(source: Vector3, w: Weapon, has_impact_position := false, impact_position := Vector3.ZERO) -> void:
	var damage_mult := 1
	var effect_keys := w.metadata_increase_ranges.keys()
	for e in weaknesses:
		if effect_keys.has(e):
			damage_mult *= 5
	var damage_dealt := damage_mult * randi_range(w.damage_range.x, w.damage_range.y)
	on_hit.emit(w, source, damage_dealt, impact_position if has_impact_position else global_position)
	if _health <= 0:
		return
	_health -= damage_dealt
	var magic_level := 1
	if w is Spell:
		magic_level = w.magic_level_requirement
	for e: BWEnum.Effect in effect_keys:
		var r := w.metadata_increase_ranges[e]
		apply_effect(e, randf_range(r.x, r.y), magic_level)
	if _health <= 0:
		on_died.emit()

func get_screen_bounds() -> Rect2:
	return BWEnum.get_bounds(global_transform, _box, get_viewport().get_camera_3d())

func apply_effect(effect: BWEnum.Effect, amount: float, weapon_magic_level: int) -> void:
	if resistances.has(effect):
		return
	if _effects.has(effect):
		_effects[effect] += amount
	else:
		_effects[effect] = amount
	var apply_chance := _effects[effect]
	if randf() <= apply_chance:
		_effects.erase(effect)
		on_effect_applied.emit(effect, weapon_magic_level)
