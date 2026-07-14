class_name QuestNotice extends CenterContainer

@onready var _quest_details: GASLabel = %QuestDetails

func set_quest_text(text: String) -> void:
	if !is_inside_tree():
		await ready
	_quest_details.text = text

func fail() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate", Color.RED, 2.0)
	t.tween_callback(queue_free)

func succeed() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate", Color.GREEN, 0.2)
	t.tween_property(self, "modulate", Color.WHITE, 0.2)
	t.tween_property(self, "modulate", Color.GREEN, 0.2)
	t.tween_property(self, "modulate", Color.WHITE, 0.2)
	t.tween_property(self, "modulate", Color.GREEN, 0.2)
	t.tween_callback(queue_free)
