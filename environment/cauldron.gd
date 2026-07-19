class_name Cauldron extends StaticBody3D

const _CAPACITY := 3

var _contents: Array[WorldItem] = []

@onready var _holders: Array[Node3D] = [%ItemHolder1, %ItemHolder2, %ItemHolder3]

func _ready() -> void:
	for h in _holders:
		h.global_position.y -= randf_range(0.0, 0.2)
		var t := create_tween()
		t.set_ease(Tween.EASE_IN_OUT)
		t.set_loops(-1)
		var speed := randf_range(3.0, 6.0)
		t.tween_property(h, "global_position:y", h.global_position.y - randf_range(0.1, 0.3), speed)
		t.tween_property(h, "global_position:y", h.global_position.y, speed)

func _on_cauldron_drop_area_body_entered(body: Node3D) -> void:
	if body is BogWitch:
		body.current_cauldron = self

func _on_cauldron_drop_area_body_exited(body: Node3D) -> void:
	if body is BogWitch:
		body.current_cauldron = null

func add_item(wi: WorldItem) -> void:
	if _contents.size() >= _CAPACITY:
		wi.queue_free()
		print("SHOULDN'T HAPPEN LADS")
		return
	_holders[_contents.size()].add_child(wi)
	_contents.append(wi)
	wi.picked_up.connect(_on_item_picked_up.bind(wi), CONNECT_ONE_SHOT)
	if _contents.size() == _CAPACITY:
		print("WE RIPE")

func _on_item_picked_up(wi: WorldItem) -> void:
	var items: Array[WorldItem] = []
	for h in _holders:
		if h.get_child_count() > 0:
			var n := h.get_child(0)
			items.append(n)
			h.remove_child(n)
	_contents.erase(wi)
	for i in items.size():
		_holders[i].add_child(items[i])
