class_name Door extends Node3D

@export var door_id: StringName
@export var animation: AnimationPlayer

var _opened := false

@onready var _body_collider: CollisionShape3D = %BodyCollider

func _on_area_3d_body_entered(body: Node3D) -> void:
	if _opened:
		return
	if body is not BogWitch:
		return
	var key := _get_key()
	if key != null:
		Player.data.inventory.remove_item(key)
		_body_collider.disabled = true
		_opened = true
		if animation != null:
			animation.play(&"open")

func _get_key() -> InventoryDetail:
	for id in Player.data.inventory.items:
		var i := id.item
		if i is KeyItem:
			if i.door_id == door_id:
				return id
	return null
