class_name HitParticle extends Node3D

@onready var _damage_number: Label3D = %DamageNumber
@onready var _whack_anim: AnimatedSprite3D = %WhackAnim
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

func set_damage(dmg: int, fatal: bool) -> void:
	if !is_inside_tree():
		await ready
	_damage_number.text = str(dmg)
	if fatal:
		_whack_anim.speed_scale = 0.25
		_animation_player.speed_scale = 0.25
		_damage_number.modulate = Color.RED

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
