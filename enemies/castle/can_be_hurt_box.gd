class_name CanBeHurtBox extends Area3D

const _OUCHIE := preload("uid://ni2oyb1sktk0")
const _BOOM := preload("uid://cv0nw6usfoc80")

@export var health := 15

@export var spawn_source: Node3D

@export var parts_to_destroy: Array[Node3D] = []

var will_hurt_player := true

func receive_hit(w: Weapon) -> void:
	var damage_dealt := floori(randi_range(w.damage_range.x, w.damage_range.y) / 2.0)
	var ouch: HitParticle = _OUCHIE.instantiate()
	health -= damage_dealt
	ouch.set_damage(damage_dealt, health <= 0)
	spawn_source.add_child(ouch)
	ouch.global_position = global_position
	if health > 0:
		return
	var boom: Node3D = _BOOM.instantiate()
	spawn_source.add_child(boom)
	boom.global_position = global_position
	for n in parts_to_destroy:
		n.queue_free()
	queue_free()
