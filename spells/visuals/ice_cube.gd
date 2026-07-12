class_name IceCube extends Node3D

@onready var _cube: Node3D = %ice_cube

func fit_to_box(box: BoxShape3D) -> void:
	_cube.scale = box.size
