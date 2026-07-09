class_name BogWitch extends PlayerCharacter

const _WEAPON_SLOTS: Array[StringName] = [
	&"weapon_slot_1", &"weapon_slot_2", &"weapon_slot_3", &"weapon_slot_4", &"weapon_slot_5",
	&"weapon_slot_6", &"weapon_slot_7", &"weapon_slot_8", &"weapon_slot_9", &"weapon_slot_0"
]

var current_weapon: Weapon

var _weapon_cooldown := 0.0
var _mouse_ray_length := 50.0

@onready var _projectile_launch_spot: Node3D = %ProjectileSpot

func _input(event: InputEvent) -> void:
	if _try_switch_weapon(event):
		return

func _process(delta: float) -> void:
	super(delta)
	_handle_attack(delta)

func _try_switch_weapon(event: InputEvent) -> bool:
	for i in _WEAPON_SLOTS.size():
		if GASInput.is_event_action_just_pressed(event, _WEAPON_SLOTS[i]):
			current_weapon = Player.data.get_weapon(i)
			print("current weapon is %s" % current_weapon)
			_weapon_cooldown = 0.0
			return true
	return false

func _handle_attack(delta: float) -> void:
	if _weapon_cooldown > 0.0:
		_weapon_cooldown -= delta
	if _weapon_cooldown > 0.0 || current_weapon == null || !Input.is_action_pressed(&"attack"):
		return
	current_weapon.use(self)
	_weapon_cooldown = current_weapon.cooldown

func get_projectile_launch_point() -> Vector3:
	return _projectile_launch_spot.global_position

func get_mouse_center() -> Vector3:
	var center := get_viewport().get_visible_rect().size / 2.0
	var from := cam.project_ray_origin(center)
	var to := from + cam.project_ray_normal(center) * _mouse_ray_length

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)

	if result:
		return result["position"]
	return to
