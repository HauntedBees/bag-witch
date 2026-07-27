class_name InventoryStandardCharacter extends Node3D

var item: Item

@onready var _character_container: Node3D = %CharacterContainer
@onready var _hit_particle: HitParticle = %HitParticle

func _ready() -> void:
	var scene: PackedScene = load(item.custom_equip_scene_inner)
	var node: Node3D = scene.instantiate()
	_character_container.add_child(node)

func show_damage(damage: int, fatal: bool, stale: bool) -> void:
	_hit_particle.set_damage(damage, fatal, stale, true)
