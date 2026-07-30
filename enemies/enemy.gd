class_name EnemyDisplay extends CharacterBody3D

const _ANIMAL_SCENE := preload("uid://dv85nim1mtt6w")
const _SNEAK_ANGLE := PI / 2.5
const _POP_SOUND := preload("uid://cuke0m0ydhchd")

signal on_died()
signal on_target_identified()
signal on_hit(w: Weapon, dir: Vector3, damage_dealt: int, impact_position: Vector3, sneak_attack: bool)
signal on_effect_applied(e: BWEnum.Effect, level: int)

## This should be obvious.
@export var enemy_name := ""

## Whether to use "Rig_Medium_etc_etc" as the default animation values or not.
@export var is_new_anims := false

@export var potential_drops: Array[Item] = []

@export var potential_drop_chance := 0.5

@export_category("Bagging")

## What level your "Strength" ability needs to be to bag this enemy.
## Since the maximum Strength level is 3, 4 means an enemy cannot be bagged.
@export_range(1, 4) var capture_level := 4

## The time it takes to suck this enemy into your bag.
@export var suck_time := 1.0

## The item gained when you suck this motherfucker up.
@export var suck_drop: Item

@export var can_be_picked_up_while_dead := true

## The WorldItem that is created when you toss this motherfucker in a stew.
## Default is a skeleton.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var cauldron_scene := "uid://b7kthsncg8yug"

@export_category("Navigation")
## The nav agent for this enemy.
@onready var nav: NavigationAgent3D = $NavigationAgent3D

## To be passed to an EnemyWalkBetweenPoints behavior if one exists.
@export var point_collection: PointCollection3D

@export_category("Hurtage")
## The enemy's max health and initial health.
@export var max_health := 100

## How long they flinch for when stunned.
@export var damage_stun_time := 0.2

## Things that hurt them more.
@export var weaknesses: Array[BWEnum.Effect] = []

## Effects that don't apply to them.
@export var resistances: Array[BWEnum.Effect] = []

@export var weakness_multiplier := 4

@export_category("Visuals")
## For the HUD.
@export var bounding_box: CollisionShape3D

## The animation player for this enemy.
@export var animation_player: AnimationPlayer

@export var idle_anims: Array[StringName] = []

@export var hit_anim: StringName

@export var big_hit_anim: StringName

@export var die_anims: Array[StringName] = []

@export var animal_spawn_count := 1

@export_category("Sounds")

@export var attack_sound: AudioStream

@export var hit_sound: AudioStream

@export var death_sound: AudioStream

var target: BogWitch

var health := 100
var suck_time_remaining := 1.0
var _effects: Dictionary[BWEnum.Effect, float] = {}
var _player_for_distance_checks: Node3D
var _sound := GASAudioStreamPlayer3D.new()

@onready var _frozen_state := EnemyFrozen.new()
@onready var _common_states: Array[EnemyBehavior] = [
	EnemyReceiveDamage.new(damage_stun_time, hit_anim, big_hit_anim),
	EnemyDead.new(die_anims),
	_frozen_state
]

@onready var alive_collider: CollisionShape3D = %CollisionShape3D
@onready var death_collider: CollisionShape3D = %DeathCollisionShape3D
@onready var _box: BoxShape3D = bounding_box.shape

func _init() -> void:
	if die_anims.size() == 0:
		die_anims.append(Anim.NewKayKit.DIE if is_new_anims else Anim.OldKayKit.DIE)

func _ready() -> void:
	add_child(_sound)
	add_to_group(&"enemy")
	suck_time_remaining = suck_time
	_player_for_distance_checks = get_tree().get_first_node_in_group(&"PlayerCharacter")
	for c in _common_states:
		add_child(c)
	health = max_health
	if idle_anims.size() == 0:
		idle_anims.append(Anim.NewKayKit.IDLE if is_new_anims else Anim.OldKayKit.IDLE)
	if hit_anim.is_empty():
		hit_anim = Anim.NewKayKit.HIT if is_new_anims else Anim.OldKayKit.HIT
	if big_hit_anim.is_empty():
		big_hit_anim = Anim.NewKayKit.BIG_HIT if is_new_anims else Anim.OldKayKit.BIG_HIT
	if animation_player != null:
		animation_player.play(idle_anims.pick_random())
	_addtl_enemy_setup()
	if health <= 0:
		_die(false)

## Called after _ready
func _addtl_enemy_setup() -> void:
	pass

func _on_peer_called_for_help(new_target: BogWitch, source_position: Vector3, allowed_radius: float) -> void:
	if global_position.distance_to(source_position) > allowed_radius:
		return
	target = new_target
	on_target_identified.emit()

func is_in_danger() -> bool:
	return health <= (0.1 * max_health)

func is_dead() -> bool:
	return health <= 0

func _process(delta: float) -> void:
	for e: BWEnum.Effect in _effects.keys():
		_effects[e] -= delta
		if _effects[e] <= 0.0:
			_effects.erase(e)
	suck_time_remaining = minf(suck_time_remaining + 0.25 * delta, suck_time)

func _physics_process(delta: float) -> void:
	#if _player_for_distance_checks != null:
	#	var dist := global_position.distance_squared_to(_player_for_distance_checks.global_position)
	#	if dist > 4900.0:
	#		return
	if !is_on_floor():
		velocity.y -= 5.0
	if is_dead():
		velocity = lerp(
			velocity,
			Vector3(0.0, velocity.y, 0.0),
			delta
		)
	move_and_slide()

func take_specific_damage(damage_dealt: int) -> void:
	if health <= 0:
		return
	health -= damage_dealt
	if health <= 0:
		_die()

func receive_weapon_hit(source: Vector3, w: Weapon, has_impact_position := false, impact_position := Vector3.ZERO) -> void:
	var damage_mult := 1
	var effect_keys := w.metadata_increase_ranges.keys()
	var sneak_attack := false
	if w.is_melee:
		match Player.data.strength:
			2: damage_mult = 2
			3: damage_mult = 4
	for e in weaknesses:
		if effect_keys.has(e):
			damage_mult *= weakness_multiplier
	for e in resistances:
		if effect_keys.has(e):
			damage_mult /= 2
	if _is_frozen() && w.is_high_impact:
		damage_mult *= 2
	if w.is_melee:
		var diff := _get_angle_diff(source)
		if diff >= _SNEAK_ANGLE:
			sneak_attack = true
			damage_mult *= 3
	if effect_keys.has(BWEnum.Effect.Burn) && Player.data.has_potion_ability(Potion.Ability.LavaInfusion):
		damage_mult *= 4
	if Player.data.has_potion_ability(Potion.Ability.SuperPower):
		damage_mult *= 3 * Player.data.get_potion_metadata(Potion.Ability.SuperPower, true)
	var damage_dealt := damage_mult * randi_range(w.damage_range.x, w.damage_range.y)
	if w is Bolt && randf() <= 0.1:
		damage_dealt *= 100
	if hit_sound == null:
		hit_sound = load("uid://dxbd2xstayq72")
	_sound.stream = hit_sound
	_sound.play()
	on_hit.emit(w, source, damage_dealt, impact_position if has_impact_position else global_position, sneak_attack)
	if is_dead():
		return
	if damage_dealt >= floori(max_health * 0.2) && randf() <= 0.75: # in addition to regular potential drop check
		_try_drop(true)
	health -= damage_dealt
	var magic_level := 1
	if w is Spell:
		magic_level = w.magic_level_requirement
	for e: BWEnum.Effect in effect_keys:
		var r := w.metadata_increase_ranges[e]
		apply_effect(e, randf_range(r.x, r.y), magic_level)
	if health <= 0:
		_die()

func _handle_knockback() -> void:
	pass

func _get_angle_diff(pos: Vector3) -> float:
	var my_dir := -transform.basis.z
	var target_dir := global_position.direction_to(pos)
	target_dir.y = 0.0
	return my_dir.angle_to(target_dir)

## "from_being_killed" as opposed to from being dropped as a corpse from inventory
func _die(from_being_killed := true) -> void:
	if from_being_killed:
		_try_animal_spawn()
		_try_drop()
		if death_sound == null:
			death_sound = load("uid://bpbt3oy3ft77s")
		_sound.stream = death_sound
		_sound.play()
	set_collision_layer_value(4, false)
	on_died.emit()

func _try_animal_spawn() -> void:
	if animal_spawn_count == 0:
		return
	for i in animal_spawn_count:
		var animal: FleeAnimal = _ANIMAL_SCENE.instantiate()
		get_parent().add_child(animal)
		animal.global_position = global_position + Vector3(0.0, 2.0, 0.0)

func _try_drop(forced := false) -> void:
	if potential_drops.size() == 0:
		return
	if randf() > potential_drop_chance:
		return
	_sound.stream = _POP_SOUND
	_sound.play()
	# slightly prioritize the first item
	var item: Item = potential_drops[0] if randf() <= 0.2 else potential_drops.pick_random()
	var wi := item.get_world_item()
	get_parent().get_parent().add_child(wi)
	wi.global_position = global_position + Vector3.UP
	var drop_range := 4.0 if forced else 1.0
	wi.plep(Vector3(randf_range(-drop_range, drop_range), 0.0, randf_range(-drop_range, drop_range)))

func is_about_to_die(damage: int) -> bool:
	return damage >= health

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

func _is_frozen() -> bool:
	return _frozen_state.is_frozen()
