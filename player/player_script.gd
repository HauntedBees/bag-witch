class_name BogWitch extends PlayerCharacter

var glide_steps := 0
var ready_to_glide := false

var _mouse_ray_length := 50.0
var _current_target: WorldItem
var _in_inventory := false

@onready var speed_lines: ColorRect = %SpeedLines
@onready var arms_overlay: ArmsOverlay = %ArmsOverlay

@onready var _projectile_launch_spot: Node3D = %ProjectileSpot
@onready var _front_check: RayCast3D = %FrontCheck
@onready var _item_select: ItemSelect = %ItemSelect

func _input(event: InputEvent) -> void:
	if _in_inventory:
		return
	if _try_switch_weapon(event):
		return
	if _try_pick_up_item(event):
		return

func _process(delta: float) -> void:
	super(delta)
	_handle_non_mouse_camera_movement()
	_handle_front_raycast()
	_handle_attack(delta)
	if is_on_floor():
		ready_to_glide = false

func _on_jump_state_jumped() -> void:
	if Player.data.current_weapon == null || Player.data.current_weapon is not Broom:
		return
	var vel := velocity
	vel.y = 0.0
	var front_dir := get_front_direction(false)
	front_dir.y = 0.0
	front_dir = front_dir.normalized()
	var vel_dir := vel.normalized()
	if vel_dir.dot(front_dir) >= 0.9 && vel.length() >= 20.0 && !is_on_floor():
		ready_to_glide = true

func get_front_direction(normalized := true) -> Vector3:
	var dir := _front_check.to_global(_front_check.target_position) - _front_check.global_position
	if normalized:
		return dir.normalized()
	return dir

func _handle_non_mouse_camera_movement() -> void:
	var mouse_dir := Vector2(
		Input.get_action_strength(&"camera_left") - Input.get_action_strength(&"camera_right"),
		Input.get_action_strength(&"camera_up") - Input.get_action_strength(&"camera_down") #TODO: invert axis option?
	)
	if mouse_dir != Vector2.ZERO:
		cam_holder.keyboard_touch(mouse_dir)

func _handle_front_raycast() -> void:
	var obj := _front_check.get_collider()
	if obj == null:
		_item_select.visible = false
		_current_target = null
		return
	if obj is WorldItem:
		_item_select.set_from_world_item(obj)
		_current_target = obj
	elif obj is EnemyDisplay:
		_item_select.set_from_enemy(obj)
	else:
		_current_target = null

func _try_pick_up_item(event: InputEvent) -> bool:
	if _current_target == null || !GASInput.is_event_action_just_pressed(event, &"use"):
		return false
	var item := _current_target.item
	var potential_add := Player.data.inventory.get_item_if_fits(item)
	if !potential_add:
		print("NO ROOM!")
		return false
	Player.data.inventory.add_item_detail(potential_add)
	_current_target.queue_free()
	_current_target = null
	return true

func _try_switch_weapon(event: InputEvent) -> bool:
	for i in BWEnum.WEAPON_SLOTS.size():
		if GASInput.is_event_action_just_pressed(event, BWEnum.WEAPON_SLOTS[i]):
			Player.try_change_weapon(i)
			glide_steps = 0
			print("current weapon is %s" % Player.data.current_weapon)
			Player.weapon_cooldown = 0.0
			return true
	return false

func _handle_attack(delta: float) -> void:
	if _in_inventory:
		return
	if Player.weapon_cooldown > 0.0:
		Player.weapon_cooldown -= delta
	if Player.weapon_cooldown > 0.0 || Player.data.current_weapon == null || !Input.is_action_pressed(&"attack"):
		return
	if Player.data.get_loaded_ammo(Player.data.current_weapon) == 0:
		return
	Player.data.current_weapon.use(self)
	Player.weapon_cooldown = Player.data.current_weapon.cooldown

func get_projectile_launch_point() -> Vector3:
	return _projectile_launch_spot.global_position

func get_mouse_center() -> Vector3: #TODO: maybe replace now that _front_check exists
	var center := get_viewport().get_visible_rect().size / 2.0
	var from := cam.project_ray_origin(center)
	var to := from + cam.project_ray_normal(center) * _mouse_ray_length

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)

	if result:
		return result["position"]
	return to

func _on_inventory_toggled(shown: bool) -> void:
	_in_inventory = shown

func _on_inventory_display_spawn_item(i: WorldItem) -> void:
	get_parent().add_child(i)
	var center := get_viewport().get_visible_rect().size / 2.0
	var to := cam.project_ray_normal(center)
	i.global_position = global_position + to * 2.0
	i.plep(to)
