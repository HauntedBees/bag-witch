class_name WorldItem extends Area3D

@export var item: Item
@export var collider: CollisionShape3D

@onready var _box: BoxShape3D = collider.shape

func get_screen_bounds() -> Rect2:
	return BWEnum.get_bounds(global_position, _box, get_viewport().get_camera_3d())
