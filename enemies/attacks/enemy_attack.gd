class_name EnemyAttack extends Node3D

@export var area: Area3D
@export var anim: AnimationPlayer

## If the node should be rotated 180 degrees at startup.
@export var flip_on_load := true

## If the attack should end if it hits the player.
@export var end_on_hit := false

## How far back the player should be knocked when hit. Should be a big number.
@export var knockback := 0.0

## How far the player should be knocked up (ayy lmao) when hit.  Should be a small number.
@export var additional_y_knockback := 0.0

## Set by attacker.
var knockback_source := Vector3.ZERO

## How much damage the player should take when hit.
@export var damage_range := Vector2i.ZERO

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	anim.animation_finished.connect(_on_animation_finished)
	if flip_on_load:
		rotate_y(PI)

func _on_body_entered(body: Node3D) -> void:
	if body is BogWitch:
		if _does_attack_land():
			body.take_damage(
				randi_range(damage_range.x, damage_range.y),
				knockback_source,
				knockback,
				additional_y_knockback
			)
		else:
			print("DODGED!")
		if end_on_hit:
			queue_free()

func _on_animation_finished(_name: StringName) -> void:
	queue_free()

func _does_attack_land() -> bool:
	match Player.data.speed:
		3: return randf() <= 0.72
		2: return randf() <= 0.88
	return randf() <= 0.95
