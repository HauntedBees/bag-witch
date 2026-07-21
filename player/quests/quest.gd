class_name Quest extends RefCounted

signal ended()

var _quest_name := &""
var _succeeded := false

var display: QuestNotice:
	set(value):
		display = value
		_set_display_text()

func _init(quest: StringName) -> void:
	_quest_name = quest

func process(_delta: float) -> void:
	pass

func did_succeed() -> bool:
	return _succeeded

func succeed() -> void:
	display.succeed()
	Player.complete_quest(_quest_name)
	_do_success_thing()
	_succeeded = true
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
