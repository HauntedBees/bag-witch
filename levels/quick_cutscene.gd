class_name QuickCutscene extends Cutscene

@export var is_tutorial := false
@export var speaker := "Bag Witch"
@export_multiline() var text: String

func _init_cutscene() -> void:
	if is_tutorial && !Player.data.options.tooltips:
		return
	SignalBus.say_thing.emit(speaker, text, "")
	Player.complete_quest(completed_key)
