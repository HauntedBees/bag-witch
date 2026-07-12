extends Node3D

func _ready() -> void:
	_try_groupify(self)

func _try_groupify(c: Node3D) -> void:
	if c is StaticBody3D:
		c.add_to_group(&"snow")
	else:
		for ch in c.get_children():
			_try_groupify(ch)
