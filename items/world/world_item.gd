class_name WorldItem extends Area3D

@export var item: Item
@export var collider: CollisionShape3D

@onready var _box: BoxShape3D = collider.shape

func get_screen_bounds() -> Rect2:
	var cam := get_viewport().get_camera_3d()
	var extents := _box.size / 2.0
	var corners: Array[Vector3] = [
		Vector3(-extents.x, -extents.y, -extents.z),
		Vector3(extents.x, -extents.y, -extents.z),
		Vector3(-extents.x, extents.y, -extents.z),
		Vector3(extents.x, extents.y, -extents.z),
		Vector3(-extents.x, -extents.y, extents.z),
		Vector3(extents.x, -extents.y, extents.z),
		Vector3(-extents.x, extents.y, extents.z),
		Vector3(extents.x, extents.y, extents.z)
	]
	var screen_corners: Array[Vector2] = []
	for corner in corners:
		var pos := global_position + corner
		if cam.is_position_behind(pos):
			continue
		screen_corners.append(cam.unproject_position(pos))

	var c_min := screen_corners[0]
	var c_max := screen_corners[0]
	for p in screen_corners:
		c_min.x = min(c_min.x, p.x)
		c_min.y = min(c_min.y, p.y)
		c_max.x = max(c_max.x, p.x)
		c_max.y = max(c_max.y, p.y)

	return Rect2(c_min, c_max - c_min)
