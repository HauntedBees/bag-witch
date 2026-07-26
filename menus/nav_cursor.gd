extends Control

var _last_node: Control

func _ready() -> void:
	_bind_navs.call_deferred()
	GASText.font_scale_changed.connect(_reposition_from_resize, CONNECT_DEFERRED)

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
	_last_node = c
	global_position = c.get_cursor_pos() #+ Vector2(0.0, c.size.y / 2.0)

func _on_mouse_entered(c: Control) -> void:
	_last_node = c
	global_position = c.global_position + Vector2(0.0, c.size.y / 2.0)

func _reposition_from_resize() -> void:
	if _last_node == null || !is_instance_valid(_last_node) || !_last_node.is_inside_tree():
		return
	await get_tree().process_frame
	if _last_node is BaseOption:
		global_position = _last_node.get_cursor_pos()
	else:
		global_position = _last_node.global_position + Vector2(0.0, _last_node.size.y / 2.0)
