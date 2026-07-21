class_name WorldItem extends Area3D

@warning_ignore("unused_signal")
signal picked_up()

@export var item: Item

## If true, this instance won't appear below a certain generation.
@export var remove_if_below_generation := false

## This is the certain generation.
@export var generation_to_remove := BWEnum.Gen.Mid

@export var from_inventory := false

@export var mods: Array[ItemMod] = []

## Should have a BoxShape3D for UI reasons.
@export var collider: CollisionShape3D

## The amount of ammo this item has on it. Only applies if the Item is a ProjectileWeapon
## or ammo and if "had_ammo_set" is true.
@export var ammo := 0

## If true, "ammo" is used for the InventoryDetail's ammo count, otherwise, a random value
## is picked from the item's "initial_ammo_range" property.
@export var had_ammo_set := false

@onready var _box: BoxShape3D = collider.shape

var _plepping := false
var _plep_dir := Vector3.ZERO
var _plep_ray: RayCast3D

func _ready() -> void:
	if remove_if_below_generation:
		# doesn't factor in Early because why the fuck would I do that
		var remove_gen := BWEnum.GEN_LATE if generation_to_remove == BWEnum.Gen.Late else BWEnum.GEN_MID
		if Player.data.generations_elapsed < remove_gen:
			print("freeing %s" % name)
			queue_free()

func get_item_name() -> String:
	var n := item.name
	if mods.size() > 0:
		n = "Modded %s" % n
	if item.is_ammo_applicable():
		if !had_ammo_set:
			had_ammo_set = true
			if item is Ammo:
				ammo = randi_range(item.initial_ammo_range.x, item.initial_ammo_range.y)
			elif item is ProjectileWeapon:
				ammo = randi_range(item.initial_ammo_range.x, item.initial_ammo_range.y)
		return "%s (%s)" % [n, ammo]
	elif item is StatCrystal:
		return "%s Shard" % n
	else:
		return n

func get_screen_bounds() -> Rect2:
	return BWEnum.get_bounds(global_transform, _box, get_viewport().get_camera_3d())

func _physics_process(delta: float) -> void:
	if !_plepping:
		return
	global_position += _plep_dir * delta * 7.0
	if _plep_ray.is_colliding():
		_plepping = false
		_plep_ray.queue_free()
		_plep_ray = null

func plep(dir: Vector3) -> void:
	_plepping = true
	rotate_y(randf_range(0.0, TAU))
	dir.y -= 1.0
	dir = dir.normalized()
	_plep_dir = dir
	_plep_ray = RayCast3D.new()
	_plep_ray.target_position = Vector3(0.0, -0.2, 0.0)
	add_child(_plep_ray)
