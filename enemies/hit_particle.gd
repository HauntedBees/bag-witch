class_name HitParticle extends Node3D

@onready var _damage_number: Label3D = %DamageNumber

func set_damage(dmg: int) -> void:
	if !is_inside_tree():
		await ready
	_damage_number.text = str(dmg)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
