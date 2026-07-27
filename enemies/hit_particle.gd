class_name HitParticle extends Node3D

@export var single_use := true

@onready var _damage_number: Label3D = %DamageNumber
@onready var _whack_anim: AnimatedSprite3D = %WhackAnim
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

func set_damage(dmg: int, fatal: bool, stale := false, reset_anim := false) -> void:
	if !is_inside_tree():
		await ready
	_damage_number.text = str(dmg)
	if stale:
		_whack_anim.speed_scale = 1.0
		_animation_player.speed_scale = 1.0
		_damage_number.modulate = Color.DIM_GRAY
	elif fatal:
		_whack_anim.speed_scale = 0.25
		_animation_player.speed_scale = 0.25
		_damage_number.modulate = Color.RED
	if reset_anim:
		visible = true
		_animation_player.play(&"NumberDangle")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if single_use:
		queue_free()
	else:
		visible = false
