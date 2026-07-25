extends Control

func _ready() -> void:
	_bind_navs.call_deferred()

func _bind_navs() -> void:
	var nodes := get_tree().get_nodes_in_group(&"trigger_nav_cursor")
	for n in nodes:
		if n is BaseOption:
			n.mouse_entered.connect(_on_mouse_entered_option, CONNECT_APPEND_SOURCE_OBJECT)
		elif n is Control:
			n.mouse_entered.connect(_on_mouse_entered, CONNECT_APPEND_SOURCE_OBJECT)
		else:
			printerr("%s needs to be a Control node to work with NavCursor." % n.name)

func _on_mouse_entered_option(c: BaseOption) -> void:
	global_position = c.get_cursor_pos() #+ Vector2(0.0, c.size.y / 2.0)

func _on_mouse_entered(c: Control) -> void:
	global_position = c.global_position + Vector2(0.0, c.size.y / 2.0)
