class_name BWEnum extends Object

const WEAPON_SLOTS: Array[StringName] = [
	&"weapon_slot_1", &"weapon_slot_2", &"weapon_slot_3", &"weapon_slot_4", &"weapon_slot_5",
	&"weapon_slot_6", &"weapon_slot_7", &"weapon_slot_8", &"weapon_slot_9", &"weapon_slot_0"
]

enum Effect {
	None,
	Freeze,
	Burn
}

static func path_to_points(p: Path3D) -> Array[Vector3]:
	var points: Array[Vector3] = []
	for i in p.curve.point_count:
		points.append(p.curve.get_point_position(i))
	return points

static func get_bounds(base_pos: Transform3D, box: BoxShape3D, cam: Camera3D) -> Rect2:
	var extents := box.size / 2.0
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
		var pos := base_pos * corner
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
