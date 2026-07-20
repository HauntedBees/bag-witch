class_name TextContainer extends MarginContainer

const _TIME_PER_CHAR := 0.025
const _INPUT_SIZE := 16
const _ICON_SIZE := 32

enum TextPriority {
	## If message is higher priority than the current message, replace it,
	## otherwise, add it to the queue.
	QueueIfLessImportantReplaceOtherwise,
	## If message is higher priority than the current message, replace it,
	## otherwise, ignore it.
	IgnoreIfLessImportantReplaceOtherwise,
	## Message is added to queue no matter what.
	AlwaysQueueAfterCurrent
}

var _is_active := false
var _current_tween: Tween
var _current_priority := -1
var _queued_messages: Array[QueuedMessage] = []
var _regex := RegEx.new()

@onready var _speaker: GASLabel = %Speaker
@onready var _body: GASRichTextLabel = %Body
@onready var _message_waiting: TextureRect = %MessageWaiting

func _ready() -> void:
	SignalBus.say_thing.connect(_say_words_from_signal)
	SignalBus.say_new_item_text.connect(_say_new_item_words_from_signal)
	SignalBus.portal_entered.connect(_on_entered_portal)

func _on_entered_portal() -> void:
	_queued_messages.clear()
	if _current_tween:
		_current_tween.kill()
		_current_tween = null
	_current_priority = -1
	visible = false
	_is_active = false

func _say_new_item_words_from_signal(speaker: String, text: String, id: String) -> void:
	say_words(speaker, text, 1, TextPriority.IgnoreIfLessImportantReplaceOtherwise, id)

func _say_words_from_signal(speaker: String, text: String, id: String) -> void:
	say_words(speaker, text, 1, TextPriority.AlwaysQueueAfterCurrent, id)

func say_words(speaker: String, text: String, priority := 0, action := TextPriority.QueueIfLessImportantReplaceOtherwise, id := "") -> void:
	if _is_active:
		match action:
			TextPriority.QueueIfLessImportantReplaceOtherwise:
				if priority < _current_priority:
					_add_to_queue(speaker, text, id)
					return
			TextPriority.IgnoreIfLessImportantReplaceOtherwise:
				if priority < _current_priority:
					return
			TextPriority.AlwaysQueueAfterCurrent:
				_add_to_queue(speaker, text, id)
				return
	if _is_active: # Replacing an existing one.
		if _current_tween != null:
			_current_tween.kill()
			_current_tween = null
	_message_waiting.visible = !_queued_messages.is_empty()
	visible = true
	_current_priority = priority
	_is_active = true
	_speaker.text = speaker
	_body.text = _process_input_text(text)
	_body.visible_characters = 0
	var tlen := text.length()
	_current_tween = create_tween()
	_current_tween.tween_property(_body, "visible_characters", tlen, _TIME_PER_CHAR * tlen)
	_current_tween.finished.connect(_on_tween_finished)

func _add_to_queue(speaker: String, text: String, id: String) -> void:
	_message_waiting.visible = true
	_queued_messages.append(QueuedMessage.new(speaker, text, id))

func _on_tween_finished() -> void:
	_current_tween = null

func _input(event: InputEvent) -> void:
	if !_is_active:
		return
	if GASInput.is_event_action_just_pressed(event, &"advance_text"):
		if _current_tween == null:
			_is_active = false
			if _queued_messages.size() == 0:
				visible = false
				SignalBus.text_ended.emit()
			else:
				var next: QueuedMessage = _queued_messages.pop_front()
				SignalBus.text_advanced.emit(next.id)
				say_words(next.speaker, next.text)
		else:
			_body.visible_ratio = 1.0
			_current_tween.kill()
			_current_tween = null

func _process_input_text(t: String) -> String:
	_regex.compile("\\[input=([a-z0-9_]+)\\]")
	var ms := _regex.search_all(t)
	var icon_text_size := _get_icon_size()
	for m in ms:
		var action := _get_appropriate_input_event(m.get_string(1))
		var rect := _get_icon_rect(action)
		t = t.replace(m.get_string(0), "[img width=%s height=%s region=%s,%s,%s,%s]res://assets/sprites/input_icons.png[/img]" % [
			icon_text_size,
			icon_text_size,
			rect[0],
			rect[1],
			rect[2],
			rect[3]
		])
	return t

func _get_icon_size() -> int:
	return 38

func _get_icon_rect(action: InputEvent) -> Array[int]:
	var idx := 0
	if action == null:
		idx = 208
	elif action is InputEventMouseButton:
		var am := action as InputEventMouseButton
		if am.button_index > 8:
			idx = 10
		else:
			idx = 2 + am.button_index
	elif action is InputEventKey:
		var ak := action as InputEventKey
		var keycode := ak.keycode
		if keycode == 0 && ak.physical_keycode > 0:
			keycode = DisplayServer.keyboard_get_keycode_from_physical(ak.physical_keycode)
		if keycode >= 4194304:
			idx = 68 + keycode - 4194304
		else:
			idx = keycode - 32
	elif action is InputEventJoypadButton:
		var ab := action as InputEventJoypadButton
		if ab.button_index > 15:
			idx = 31
		else:
			var joy_name := Input.get_joy_name(0).to_lower()
			idx = 128 + ab.button_index + _get_console_offset(joy_name, ab.button_index > 10)
	elif action is InputEventJoypadMotion:
		var am := action as InputEventJoypadMotion
		idx = 192
		var joy_name := Input.get_joy_name(0).to_lower()
		match am.axis:
			JOY_AXIS_LEFT_X: idx += 4 if sign(am.axis_value) < 0 else 6
			JOY_AXIS_LEFT_Y: idx += 5 if sign(am.axis_value) < 0 else 7
			JOY_AXIS_RIGHT_X: idx += 8 if sign(am.axis_value) < 0 else 10
			JOY_AXIS_RIGHT_Y: idx += 9 if sign(am.axis_value) < 0 else 11
			JOY_AXIS_TRIGGER_LEFT: idx += 12 + _get_console_offset(joy_name, false)
			JOY_AXIS_TRIGGER_RIGHT: idx += 13 + _get_console_offset(joy_name, false)
	return [_INPUT_SIZE * (idx % 16), _INPUT_SIZE * floor(idx / 16.0), _INPUT_SIZE, _INPUT_SIZE]

func _get_console_offset(joy_name: String, joycon_different_icon: bool) -> int:
	if joy_name.begins_with("ps4") || joy_name.begins_with("ps5") || joy_name.find("sony") >= 0 || joy_name.find("dualshock") >= 0:
		return 16
	elif joy_name.find("nintendo") >= 0 || joy_name.find("pro controller") >= 0:
		return 32
	elif joy_name.find("joycon") >= 0:
		return 48 if joycon_different_icon else 32
	return 0

func _get_appropriate_input_event(action_name: String) -> InputEvent:
	var actions := InputMap.action_get_events(action_name)
	if actions.size() == 0:
		return null
	var using_joypad := GASInput.get_last_input_method() == GASInput.InputMethodType.Joypad
	for a in actions:
		if using_joypad && (a is InputEventJoypadButton || a is InputEventJoypadMotion):
			return a
		elif !using_joypad && a is InputEventKey:
			return a
	return actions[0]

class QueuedMessage extends RefCounted:
	var speaker: String
	var text: String
	var id: String
	func _init(s: String, t: String, i: String) -> void:
		id = i
		speaker = s
		text = t
