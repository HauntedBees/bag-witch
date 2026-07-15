class_name TextContainer extends MarginContainer

const _TIME_PER_CHAR := 0.025

var _is_active := false
var _current_tween: Tween
var _queued_messages: Array[QueuedMessage] = []

@onready var _speaker: GASLabel = %Speaker
@onready var _body: GASLabel = %Body
@onready var _message_waiting: TextureRect = %MessageWaiting

func say_words(speaker: String, text: String, important := true) -> void:
	if _is_active:
		if important:
			_message_waiting.visible = true
			_queued_messages.append(QueuedMessage.new(speaker, text))
		return
	_message_waiting.visible = !_queued_messages.is_empty()
	visible = true
	_is_active = true
	_speaker.text = speaker
	_body.text = text
	_body.visible_characters = 0
	var tlen := text.length()
	_current_tween = create_tween()
	_current_tween.tween_property(_body, "visible_characters", tlen, _TIME_PER_CHAR * tlen)
	_current_tween.finished.connect(_on_tween_finished)

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
			else:
				var next: QueuedMessage = _queued_messages.pop_front()
				say_words(next.speaker, next.text)
		else:
			_body.visible_ratio = 1.0
			_current_tween.kill()
			_current_tween = null

class QueuedMessage extends RefCounted:
	var speaker: String
	var text: String
	func _init(s: String, t: String) -> void:
		speaker = s
		text = t
