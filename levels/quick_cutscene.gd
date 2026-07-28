class_name QuickCutscene extends Cutscene

@export var is_tutorial := false
@export var speaker := "Bag Witch"
@export_multiline() var text: String

func _init_cutscene() -> void:
	if is_tutorial && !Player.data.options.tooltips:
		return
	SignalBus.say_thing.emit(speaker, text, "")
	# call_deferred so first_time_in_lava_world.gd can work as expected.
	Player.complete_quest.call_deferred(completed_key)
