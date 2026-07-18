class_name TextContainer extends MarginContainer

const _TIME_PER_CHAR := 0.025

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

@onready var _speaker: GASLabel = %Speaker
@onready var _body: GASLabel = %Body
@onready var _message_waiting: TextureRect = %MessageWaiting

func _ready() -> void:
	SignalBus.say_thing.connect(_say_words_from_signal)

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
	_body.text = text
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

class QueuedMessage extends RefCounted:
	var speaker: String
	var text: String
	var id: String
	func _init(s: String, t: String, i: String) -> void:
		id = i
		speaker = s
		text = t
