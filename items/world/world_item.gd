class_name WorldItem extends Area3D

@export var item: Item
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

func get_item_name() -> String:
	if item.is_ammo_applicable():
		if !had_ammo_set:
			had_ammo_set = true
			if item is Ammo:
				ammo = randi_range(item.initial_ammo_range.x, item.initial_ammo_range.y)
			elif item is ProjectileWeapon:
				ammo = randi_range(item.initial_ammo_range.x, item.initial_ammo_range.y)
		return "%s (%s)" % [item.name, ammo]
	else:
		return item.name

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
