class_name EnemyBehavior extends Node

const _DAMAGED_PRIORITY := 999
const _DEAD_PRIORITY := 9999

@export var priority := 0

var active := true:
	set(value):
		var changed := active != value
		active = value
		if changed:
			_on_active_changed()
var wants_control := false

var _parent: EnemyDisplay

func _ready() -> void:
	_parent = get_parent()
	_setup_behavior()

func _setup_behavior() -> void:
	pass

func _on_active_changed() -> void:
	pass

func _physics_process(delta: float) -> void:
	if active && !_parent.is_dead():
		_behave(delta)

func _behave(_delta: float) -> void:
	pass

func take_control() -> void:
	wants_control = true
	for c in _parent.get_children():
		if c is EnemyBehavior:
			if c.priority < priority:
				c.active = false

func _relinquish_control() -> void:
	var next_active_behavior: EnemyBehavior = null
	for c in _parent.get_children():
		if c is EnemyBehavior:
			if c == self:
				continue
			c.active = true
			if c.wants_control:
				if next_active_behavior == null:
					next_active_behavior = c
				elif c.priority > next_active_behavior.priority:
					next_active_behavior = c
	wants_control = false
	if next_active_behavior != null:
		next_active_behavior.take_control()
