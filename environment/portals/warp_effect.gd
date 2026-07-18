class_name WarpEffect extends CanvasLayer

signal finished()

@onready var _rect: ColorRect = %ColorRect
@onready var _shader: ShaderMaterial = _rect.material

var _current_tween: Tween = null

func begin() -> void:
	if _current_tween:
		_current_tween.kill()
	_current_tween = create_tween()
	_current_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_current_tween.tween_method(_tween, 0.0, 1.0, 1.0)
	_current_tween.tween_callback(_open_tween_ended)

func end() -> void:
	if _current_tween:
		_current_tween.kill()
	_current_tween = create_tween()
	_current_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_current_tween.tween_method(_tween, 1.0, 0.0, 0.5)
	_current_tween.tween_callback(_tween_ended)

func _tween(t: float) -> void:
	_shader.set_shader_parameter(&"speed", 10.0 * t)
	_shader.set_shader_parameter(&"height", 0.1 * t)

func _open_tween_ended() -> void:
	_current_tween = null

func _tween_ended() -> void:
	_current_tween = null
	finished.emit()
