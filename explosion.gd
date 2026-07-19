class_name Explosion extends Node3D

const _DPS := 5.0

var weapon: Weapon

var _gettin_boomed: Dictionary[Node3D, float] = {}

func _ready() -> void:
	var t := create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "scale", 25.0 * Vector3.ONE, 1.0)

func _on_animated_sprite_3d_animation_finished() -> void:
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is EnemyDisplay:
		body.receive_weapon_hit(global_position, weapon)
		_gettin_boomed[body] = 0.0
	elif body is BogWitch:
		body.take_damage_from_weapon(weapon, global_position)
		_gettin_boomed[body] = 0.0

func _process(delta: float) -> void:
	for b: Node3D in _gettin_boomed.keys():
		_gettin_boomed[b] += _DPS * delta
		if _gettin_boomed[b] >= 1.0:
			_gettin_boomed[b] -= 1.0
			if b is EnemyDisplay:
				b.take_specific_damage(1)
			elif b is BogWitch:
				b.take_damage(1, Vector3.ZERO, 0.0)

func _on_area_3d_body_exited(body: Node3D) -> void:
	_gettin_boomed.erase(body)
