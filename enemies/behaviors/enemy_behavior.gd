class_name EnemyBehavior extends Node

@export var priority := 0

var active := true

var _parent: EnemyDisplay

func _ready() -> void:
	_parent = get_parent()
	_setup_behavior()

func _setup_behavior() -> void:
	pass

func _physics_process(delta: float) -> void:
	if active:
		_behave(delta)

func _behave(_delta: float) -> void:
	pass

func _try_take_control() -> bool:
	var children := _parent.get_children()
	for c in children:
		if c is EnemyBehavior:
			if c.priority > priority:
				return false
	for c in children:
		if c is EnemyBehavior:
			c.active = false
	return true

func _relinquish_control() -> void:
	for c in _parent.get_children():
		if c is EnemyBehavior:
			c.active = true
