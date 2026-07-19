class_name QuickCutscene extends Cutscene

@export var speaker := "Bag Witch"
@export_multiline() var text: String

func _init_cutscene() -> void:
	SignalBus.say_thing.emit(speaker, text, "")
	Player.complete_quest(completed_key)
