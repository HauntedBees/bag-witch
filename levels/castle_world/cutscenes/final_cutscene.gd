class_name FinalCutscene extends Cutscene

@export var queen: Node3D

func _init_cutscene() -> void:
	var player: Node3D = get_tree().get_first_node_in_group(&"PlayerCharacter")
	if player:
		queen.look_at(player.global_position)
		queen.rotate_y(PI)
	SignalBus.text_ended.connect(_on_finish_queen_dialog, CONNECT_ONE_SHOT)
	SignalBus.say_thing.emit("Queen Perpetua XII", "Oh, hey! Didn't see you there! It seems the travelled has become... the traveller!", "QP12a")
	SignalBus.say_thing.emit("Queen Perpetua XII", "Anyway I guess now you've thwarted my family's plans of using animals to power our time-and-space-travel technology.", "QP12b")
	SignalBus.say_thing.emit("Queen Perpetua XII", "Which sucks.", "QP12c")
	SignalBus.say_thing.emit("Queen Perpetua XII", "For me, mostly. It'd suck for you if the developer had had time to implement a wicked final boss battle.", "QP12d")
	SignalBus.say_thing.emit("Queen Perpetua XII", "But alas. Such is the nature of game jams. Hope you had fun!", "QP12e")
	SignalBus.say_thing.emit("Queen Perpetua XII", "Check out some other great games by Haunted Bees Productions while you're here!", "QP12f")

func _on_finish_queen_dialog() -> void:
	_finish_cutscene(false)
