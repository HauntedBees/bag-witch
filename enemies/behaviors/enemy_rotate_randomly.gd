class_name EnemyRotateRandomly extends EnemyBehavior

var _time_to_next_rotate := 0.0
var _current_tween: Tween = null

func _behave(delta: float) -> void:
	_time_to_next_rotate -= delta
	if _time_to_next_rotate <= 0.0:
		var rotate_time := randf_range(0.125, 3.0)
		_time_to_next_rotate = randf_range(rotate_time * 2.0, rotate_time * 3.0)#40.0)
		_current_tween = create_tween()
		_current_tween.tween_property(_parent, "rotation:y", randf_range(-PI, PI), rotate_time)
		_current_tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
	_current_tween = null

func _on_active_changed() -> void:
	if !active && _current_tween != null:
		_current_tween.kill()
		_current_tween = null
