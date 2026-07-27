class_name BWEnum extends Object

enum Gen { Early, Mid, Late }

const GEN_MID := 4
const GEN_LATE := 10
static var ALLOW_FLIGHT := false

const WEAPON_SLOTS: Array[StringName] = [
	&"weapon_slot_1", &"weapon_slot_2", &"weapon_slot_3", &"weapon_slot_4", &"weapon_slot_5",
	&"weapon_slot_6", &"weapon_slot_7", &"weapon_slot_8", &"weapon_slot_9", &"weapon_slot_0"
]

enum Effect {
	None,
	Freeze,
	Burn,
	Shock
}

static func is_menu_action_pressed(event: InputEvent) -> bool:
	if event is InputEventMouseButton: # a mouse clicking on a button will trigger "pressed" on its own
		return false
	return GASInput.is_event_action_just_pressed(event, &"menu_confirm") \
		|| GASInput.is_event_action_just_pressed(event, &"attack")

static func get_input_dir(event: InputEvent) -> Vector2i:
	var dir := GASInput.get_vector2i_custom(
		event,
		&"play_char_move_left_action", &"play_char_move_right_action",
		&"play_char_move_forward_action", &"play_char_move_backward_action"
	)
	if dir == Vector2i.ZERO:
		dir = GASInput.get_vector2i_custom(
			event,
			&"inventory_left", &"inventory_right", &"inventory_up", &"inventory_down"
		)
	return dir

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

	if screen_corners.size() == 0:
		return Rect2(0.0, 0.0, 1.0, 1.0)

	var c_min := screen_corners[0]
	var c_max := screen_corners[0]
	for p in screen_corners:
		c_min.x = min(c_min.x, p.x)
		c_min.y = min(c_min.y, p.y)
		c_max.x = max(c_max.x, p.x)
		c_max.y = max(c_max.y, p.y)

	return Rect2(c_min, c_max - c_min)
