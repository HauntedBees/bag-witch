class_name GlideState extends State

var state_name := "Glide"

var play_char: BogWitch

var fly_speed := 0.0
var fly_accel := 0.0
var fly_deccel := 0.0

func enter(play_char_ref : CharacterBody3D) -> void:
	play_char = play_char_ref
	play_char.arms_overlay.arms.play_anim(&"BroomFly", false)
	play_char.ready_to_glide = false
	play_char.speed_lines.visible = true
	verifications()

func exit() -> void:
	play_char.speed_lines.visible = false
	play_char.arms_overlay.arms.reset_idle()

func verifications() -> void:
	fly_speed = play_char.fly_speed
	fly_accel = play_char.fly_accel
	fly_deccel = play_char.fly_deccel

	play_char.floor_snap_length = 1.0
	if play_char.jump_cooldown > 0.0: play_char.jump_cooldown = -1.0
	if play_char.nb_jumps_in_air_allowed < play_char.nb_jumps_in_air_allowed_ref: play_char.nb_jumps_in_air_allowed = play_char.nb_jumps_in_air_allowed_ref
	if play_char.coyote_jump_cooldown < play_char.coyote_jump_cooldown_ref: play_char.coyote_jump_cooldown = play_char.coyote_jump_cooldown_ref
	if play_char.has_dashed: play_char.has_dashed = false

	play_char.tween_hitbox_height(play_char.base_hitbox_height)
	play_char.tween_model_height(play_char.base_model_height)

func physics_update(delta: float) -> void:
	applies(delta)
	input_management()
	move(delta)
	if play_char.is_on_floor():
		transitioned.emit(self, "InairState")

func applies(delta: float) -> void:
	if play_char.jump_cooldown > 0.0:
		play_char.jump_cooldown -= delta
	if play_char.hit_ground_cooldown > 0.0:
		play_char.hit_ground_cooldown -= delta

func input_management() -> void:
	if Input.is_action_just_pressed(play_char.fly_action):
		transitioned.emit(self, "InairState")

func move(delta: float) -> void:
	#if play_char.move_direction:
	var new_vel := play_char.get_front_direction() * play_char.velocity.length()
	var grav_vel := new_vel
	grav_vel.y = -9.0
	play_char.velocity = lerp(new_vel, grav_vel, fly_accel * delta)
