class_name BogWitch extends PlayerCharacter

var ready_to_glide := false
var current_weapon_metadata: Dictionary[String, int] = {}
var alt_hand_for_attack_anim := false

var _mouse_ray_length := 50.0
var _current_target: WorldItem
var _in_inventory := false
var _reloading_time_remaining := 0.0

@onready var speed_lines: ColorRect = %SpeedLines
@onready var arms_overlay: ArmsOverlay = %ArmsOverlay

@onready var _projectile_launch_spot: Node3D = %ProjectileSpot
@onready var _alt_projectile_launch_spot: Node3D = %ProjectileSpot2
@onready var _front_check: RayCast3D = %FrontCheck
@onready var _item_select: ItemSelect = %ItemSelect

func _ready() -> void:
	super()
	Player.data.stat_changed.connect(_adjust_movement_stats)
	_adjust_movement_stats()

func _adjust_movement_stats() -> void:
	print("SPEED IS %s" % Player.data.speed)
	match Player.data.speed:
		1:
			max_desired_move_speed = 30.0
			run_speed = 24.0
			run_accel = 15.0
			jump_height = 2.2
		2:
			max_desired_move_speed = 35.0
			run_speed = 28.0
			run_accel = 18.0
			jump_height = 2.5
		3:
			max_desired_move_speed = 50.0
			run_speed = 40.0
			run_accel = 25.0
			jump_height = 3.0

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_7):
		Player.data.speed = 1
	if Input.is_key_pressed(KEY_8):
		Player.data.speed = 2
	if Input.is_key_pressed(KEY_9):
		Player.data.speed = 3
	if _in_inventory:
		return
	if _try_switch_weapon(event):
		return
	if _try_pick_up_item(event):
		return
	if _try_reload(event):
		return

func _process(delta: float) -> void:
	super(delta)
	if _reloading_time_remaining >= 0.0:
		_reloading_time_remaining -= delta
	_handle_non_mouse_camera_movement()
	_handle_front_raycast()
	_handle_attack(delta)
	if is_on_floor():
		ready_to_glide = false

func _on_jump_state_jumped() -> void:
	if Player.data.current_weapon_detail == null || Player.data.current_weapon() is not Broom:
		return
	var vel := velocity
	vel.y = 0.0
	var front_dir := get_front_direction(false)
	front_dir.y = 0.0
	front_dir = front_dir.normalized()
	var vel_dir := vel.normalized()
	if vel_dir.dot(front_dir) >= 0.9 && vel.length() >= 17.0 && !is_on_floor():
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

func _try_reload(event: InputEvent) -> bool:
	if _in_inventory || _reloading_time_remaining > 0.0:
		return false
	if !GASInput.is_event_action_just_pressed(event, &"reload"):
		return false
	var w := Player.data.current_weapon()
	if w == null || w.reload_time <= 0.0:
		return false
	if w is not ProjectileWeapon:
		return false
	var pw := w as ProjectileWeapon
	var remaining := pw.full_clip_size - Player.data.current_weapon_detail.ammo
	for id in Player.data.inventory.items:
		if id.item is Ammo:
			var a := id.item as Ammo
			if a.weapon != pw:
				continue
			var amount := id.ammo
			if amount == 0:
				continue
			if amount >= remaining:
				id.ammo -= remaining
				Player.data.current_weapon_detail.ammo += remaining
				remaining = 0
			else:
				Player.data.current_weapon_detail.ammo += amount
				id.ammo = 0
				remaining -= amount
		if remaining == 0:
			break
	Player.ammo_changed.emit(Player.data.current_weapon_detail.ammo)
	_reloading_time_remaining = w.reload_time
	arms_overlay.arms.play_anim(w.reload_animation)
	alt_hand_for_attack_anim = false
	return true

func _try_pick_up_item(event: InputEvent) -> bool:
	if _in_inventory:
		return false
	if _current_target == null || !GASInput.is_event_action_just_pressed(event, &"use"):
		return false
	var item := _current_target.item
	var potential_add := Player.data.inventory.get_item_if_fits(item)
	if !potential_add:
		print("NO ROOM!")
		return false
	if _current_target.had_ammo_set:
		potential_add.ammo = _current_target.ammo
	Player.data.inventory.add_item_detail(potential_add)
	_current_target.queue_free()
	_current_target = null
	return true

func _try_switch_weapon(event: InputEvent) -> bool:
	if _in_inventory || _reloading_time_remaining > 0.0:
		return false
	for i in BWEnum.WEAPON_SLOTS.size():
		if GASInput.is_event_action_just_pressed(event, BWEnum.WEAPON_SLOTS[i]):
			Player.try_change_weapon(i)
			current_weapon_metadata.clear()
			ready_to_glide = false
			print("current weapon is %s" % Player.data.current_weapon())
			Player.weapon_cooldown = 0.0
			alt_hand_for_attack_anim = false
			return true
	return false

func _handle_attack(delta: float) -> void:
	if _in_inventory || _reloading_time_remaining > 0.0:
		return
	if Player.weapon_cooldown > 0.0:
		Player.weapon_cooldown -= delta
	if Player.weapon_cooldown > 0.0 || Player.data.current_weapon_detail == null || !Input.is_action_pressed(&"attack"):
		return
	if Player.data.get_loaded_ammo(Player.data.current_weapon_detail) == 0:
		return
	Player.data.current_weapon().use(self)
	Player.weapon_cooldown = Player.data.current_weapon().cooldown

func get_projectile_launch_point(left_hand: bool) -> Vector3:
	if left_hand:
		return _alt_projectile_launch_spot.global_position
	else:
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

func _on_inventory_display_spawn_item(wi: WorldItem, id: InventoryDetail) -> void:
	wi.ammo = id.ammo
	wi.had_ammo_set = true
	get_parent().add_child(wi)
	var center := get_viewport().get_visible_rect().size / 2.0
	var to := _get_adjusted_drop_position(global_position, cam.project_ray_normal(center))
	wi.global_position = global_position + to + Vector3(0.0, 0.3, 0.0)
	wi.plep(to)

func _get_adjusted_drop_position(from: Vector3, to: Vector3) -> Vector3:
	var space_state := get_world_3d().direct_space_state
	for i: float in [2.0, 1.5, 1.0, 0.5]:
		var query := PhysicsRayQueryParameters3D.create(from, from + to * i)
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			print("FUCKED WITH %s" % i)
			return to * i
		print("can't fuck with %s" % i)
	return Vector3.ZERO
