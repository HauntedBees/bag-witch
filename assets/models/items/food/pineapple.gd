extends WorldItem

@onready var _base: Node3D = %pineapple_base

func _ready() -> void:
	_base.visible = !from_inventory
