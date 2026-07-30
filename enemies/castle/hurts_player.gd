class_name HurtPlayerBox extends Area3D

@export var health := 400

var _last_frame_pos := Vector3.ZERO
var _has_moved := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	_has_moved = (_last_frame_pos != global_position)
	_last_frame_pos = global_position

func _on_body_entered(b: Node3D) -> void:
	if b is BogWitch && _has_moved:
		b.take_damage(randi_range(40, 60), global_position, 10.0, 5.0)
