class_name Highlight extends NinePatchRect

func set_to(n: Control) -> void:
	if is_inside_tree():
		get_parent().remove_child(self)
	if n == null:
		return
	n.add_child(self)
	set_deferred(&"size", n.size)
