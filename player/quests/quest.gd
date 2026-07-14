class_name Quest extends RefCounted

signal ended()

var display: QuestNotice:
	set(value):
		display = value
		_set_display_text()

func process(_delta: float) -> void:
	pass

func succeed() -> void:
	display.succeed()
	_do_success_thing()
	_end()

func _do_success_thing() -> void:
	pass

func fail() -> void:
	display.fail()
	_end()

func _set_display_text() -> void:
	if display == null:
		return
	_set_display_text_inner()

func _set_display_text_inner() -> void:
	pass

func _end() -> void:
	display = null
	ended.emit()
