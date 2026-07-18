class_name BogWitch extends PlayerCharacter

signal quest_added(q: Quest)
signal quest_removed(q: Quest)

var ready_to_glide := false
var current_weapon_metadata: Dictionary[String, int] = {}
var alt_hand_for_attack_anim := false

var _quests: Dictionary[StringName, Quest] = {}
var _already_completed_quests: Array[StringName] = []
var _mouse_ray_length := 50.0
var _current_targeted_item: WorldItem
var _current_targeted_enemy: EnemyDisplay
var _in_inventory := false
var _reloading_time_remaining := 0.0

var _is_sucking := false
var _suck_time_remaining := 0.0
var _suck_enemy: EnemyDisplay
var _max_grab_distance := 10.0

@onready var speed_lines: ColorRect = %SpeedLines
@onready var arms_overlay: ArmsOverlay = %ArmsOverlay
@onready var text_container: TextContainer = %TextContainer

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
			wallrun_speed = 0.0
			run_speed = 24.0
			run_accel = 15.0
			jump_height = 2.2
		2:
			max_desired_move_speed = 35.0
			wallrun_speed = 9.0
			run_speed = 28.0
			run_accel = 18.0
			jump_height = 2.5
		3:
			max_desired_move_speed = 50.0
			wallrun_speed = 18.0
			run_speed = 40.0
			run_accel = 25.0
			jump_height = 3.0

func _input(event: InputEvent) -> void:
	if Player.input_locked:
		return
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
	if _try_reload(event):
		return

func _process(delta: float) -> void:
	super(delta)
	for q: Quest in _quests.values():
		q.process(delta)
	if _reloading_time_remaining >= 0.0:
		_reloading_time_remaining -= delta
	_handle_non_mouse_camera_movement()
	_handle_front_raycast()
	if !Player.input_locked:
		_handle_bag(delta)
		_handle_attack(delta)
	if is_on_floor():
		ready_to_glide = false

func already_beat_quest(key: StringName) -> bool:
	return _already_completed_quests.has(key)

func get_quest(key: StringName) -> Quest:
	if _quests.has(key):
		return _quests[key]
	return null

func set_quest(key: StringName, quest: Quest) -> void:
	_quests[key] = quest
	quest.ended.connect(_on_quest_ended.bind(key))
	quest_added.emit(quest)

func _on_quest_ended(key: StringName) -> void:
	if !_quests.has(key):
		return # shouldn't happen
	var quest := _quests[key]
	quest_removed.emit(quest)
	_quests.erase(key)

func is_on_broom() -> bool:
	return state_machine.curr_state_name == "Glide"

func _on_jump_state_jumped() -> void:
	if Player.data.current_equipped == null || Player.data.current_equipped_item() is not Broom:
		return
	var vel := velocity
	vel.y = 0.0
	var front_dir := get_front_direction(false)
	front_dir.y = 0.0
	front_dir = front_dir.normalized()
	var vel_dir := vel.normalized()
	if vel_dir.dot(front_dir) >= 0.9 && vel.length() >= 14.0 && !is_on_floor():
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
		_current_targeted_item = null
		_current_targeted_enemy = null
		return
	var found_something := false
	if obj is WorldItem:
		if obj.global_position.distance_to(global_position) <= _max_grab_distance:
			found_something = true
			_item_select.set_from_world_item(obj)
			_current_targeted_item = obj
			_current_targeted_enemy = null
	elif obj is EnemyDisplay:
		var distance := _max_grab_distance
		var i := Player.data.current_equipped_item()
		if i != null && i is not Spell:
			distance = i.use_range
		print(obj.global_position.distance_to(global_position))
		if obj.global_position.distance_to(global_position) <= distance:
			found_something = true
			_item_select.set_from_enemy(obj)
			_current_targeted_item = null
			_current_targeted_enemy = obj
	if !found_something:
		_current_targeted_item = null
		_current_targeted_enemy = null

func _try_reload(event: InputEvent) -> bool:
	if _in_inventory || _reloading_time_remaining > 0.0:
		return false
	if !GASInput.is_event_action_just_pressed(event, &"reload"):
		return false
	var w := Player.data.current_equipped_item()
	if w == null || w.reload_time <= 0.0:
		return false
	if w is not ProjectileWeapon:
		return false
	var pw := w as ProjectileWeapon
	var remaining := pw.full_clip_size - Player.data.current_equipped.ammo
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
				Player.data.current_equipped.ammo += remaining
				remaining = 0
			else:
				Player.data.current_equipped.ammo += amount
				id.ammo = 0
				remaining -= amount
		if remaining == 0:
			break
	Player.ammo_changed.emit(Player.data.current_equipped.ammo)
	_reloading_time_remaining = w.reload_time
	arms_overlay.arms.play_anim(w.reload_animation)
	alt_hand_for_attack_anim = false
	return true

func _handle_bag(delta: float) -> bool:
	if _in_inventory:
		return false
	if GASInput.is_action_just_pressed(&"use"):
		if _current_targeted_item != null:
			return _try_pick_up_item()
		elif _current_targeted_enemy != null && _current_targeted_enemy.capture_level <= Player.data.bag:
			return _try_start_enemy_sucking()
		else:
			arms_overlay.arms.play_anim(&"BagUse")
			return false
	elif Input.is_action_pressed(&"use") && _is_sucking:
		if _suck_enemy != _current_targeted_enemy:
			_suck_enemy = null
			_is_sucking = false
			return false
		arms_overlay.arms.play_anim(&"BagSuck")
		_suck_time_remaining -= delta
		if _suck_time_remaining <= 0.0:
			return _try_procure_enemy() # TODO: should do a little animation
		return true
	return false

func _try_start_enemy_sucking() -> bool:
	if Player.data.inventory.get_item_if_fits(_current_targeted_enemy.suck_drop) == null:
		arms_overlay.arms.play_anim(&"BagUse")
		text_container.say_words(
			"Bag Witch",
			"I won't be able to fit them in my bag right now... I need to either get rid of something or move some things around to fit this %sx%s %s in there..." % [
				_current_targeted_enemy.suck_drop.size.x,
				_current_targeted_enemy.suck_drop.size.y,
				_current_targeted_enemy.enemy_name
			],
			0,
			TextContainer.TextPriority.IgnoreIfLessImportantReplaceOtherwise
		)
		return false
	arms_overlay.arms.play_anim(&"BagSuck")
	_is_sucking = true
	_suck_time_remaining = _current_targeted_enemy.suck_time
	_suck_enemy = _current_targeted_enemy
	return true

func _try_procure_enemy() -> bool:
	if _current_targeted_enemy == null:
		return false
	var item := _current_targeted_enemy.suck_drop
	var added := _try_add_item(item)
	if added == null: # this shouldn't happen, since _try_start_enemy_sucking already handles this case, but better be safe!
		text_container.say_words(
			"Bag Witch",
			"I won't be able to fit them in my bag right now... I need to either get rid of something or move some things around to fit this %sx%s %s in there..." % [
				_current_targeted_enemy.suck_drop.size.x,
				_current_targeted_enemy.suck_drop.size.y,
				_current_targeted_enemy.enemy_name
			],
			0,
			TextContainer.TextPriority.IgnoreIfLessImportantReplaceOtherwise
		)
		return false
	_current_targeted_enemy.queue_free()
	_current_targeted_enemy = null
	_is_sucking = false
	_suck_enemy = null
	return true

func _try_pick_up_item() -> bool:
	arms_overlay.arms.play_anim(&"BagUse")
	var item := _current_targeted_item.item
	var added := _try_add_item(item)
	if added == null:
		text_container.say_words(
			"Bag Witch",
			"I won't be able to fit this in my bag right now... I need to either get rid of something or move some things around to fit this %sx%s item in there..." % [
				item.size.x,
				item.size.y
			],
			0,
			TextContainer.TextPriority.IgnoreIfLessImportantReplaceOtherwise
		)
		return false
	if _current_targeted_item.had_ammo_set:
		added.ammo = _current_targeted_item.ammo
	_current_targeted_item.queue_free()
	_current_targeted_item = null
	return true

func _try_add_item(item: Item) -> InventoryDetail:
	var potential_add := Player.data.inventory.get_item_if_fits(item)
	if !potential_add:
		return null
	Player.data.inventory.add_item_detail(potential_add)
	return potential_add

func _try_switch_weapon(event: InputEvent) -> bool:
	if _in_inventory || _reloading_time_remaining > 0.0:
		return false
	for i in BWEnum.WEAPON_SLOTS.size():
		if GASInput.is_event_action_just_pressed(event, BWEnum.WEAPON_SLOTS[i]):
			Player.try_change_weapon(i)
			current_weapon_metadata.clear()
			ready_to_glide = false
			print("current weapon is %s" % Player.data.current_equipped_item())
			Player.weapon_cooldown = 0.0
			alt_hand_for_attack_anim = false
			return true
	return false

func _handle_attack(delta: float) -> void:
	if _in_inventory || _reloading_time_remaining > 0.0:
		return
	if Player.weapon_cooldown > 0.0:
		Player.weapon_cooldown -= delta
	if Player.weapon_cooldown > 0.0 || Player.data.current_equipped == null || !Input.is_action_pressed(&"attack"):
		return
	if Player.data.get_loaded_ammo(Player.data.current_equipped) == 0:
		return
	var item := Player.data.current_equipped_item()
	item.use(self)
	Player.weapon_cooldown = item.usage_cooldown

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
	var query := PhysicsRayQueryParameters3D.create(from, to, 5) # alive enemies and the environment
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
