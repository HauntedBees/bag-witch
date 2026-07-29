extends WorldItem

var _RINGS := preload("uid://bhc3lbevd1b0w")

@onready var _base: Node3D = %pineapple_base

func _ready() -> void:
	_base.visible = !from_inventory
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area is SwipeArea3D:
		var p: PlayerAttack = area.swipe_attack
		if p.weapon.is_saw:
			var wi := _RINGS.get_world_item()
			get_parent().add_child(wi)
			wi.global_position = global_position
			queue_free()
