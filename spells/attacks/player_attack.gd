class_name PlayerAttack extends Node3D

@export var area: Area3D
@export var anim: AnimationPlayer

## If the attack should end if it hits the player.
@export var end_on_hit := false

var weapon: Weapon

## Set by attacker.
var knockback_source := Vector3.ZERO

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	anim.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node3D) -> void:
	if body is EnemyDisplay:
		var space_state := get_world_3d().direct_space_state
		var dir := -global_transform.basis.z.normalized()
		var query := PhysicsRayQueryParameters3D.create(global_position - dir * 2.0, global_position + dir * 100.0)
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			body.receive_weapon_hit(global_position, weapon)
		else:
			body.receive_weapon_hit(global_position, weapon, true, result["position"])
		if end_on_hit:
			queue_free()

func _on_animation_finished(_name: StringName) -> void:
	queue_free()
