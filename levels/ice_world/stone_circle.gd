extends Area3D

const _QUESTNAME := &"beaghmore"

@export var id: int
@export var is_start_or_finish_point := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is not BogWitch:
		return
	var bw := body as BogWitch
	if bw.already_beat_quest(_QUESTNAME):
		return
	var quest: BeaghmoreQuest = bw.get_quest(_QUESTNAME)
	if is_start_or_finish_point:
		if quest == null: # showing up at an end piece starts the quest
			quest = BeaghmoreQuest.new()
			quest.add_stone(id)
			bw.set_quest(_QUESTNAME, quest)
			print("STARTING")
		elif !quest.add_stone(id):
			quest.fail()
	else:
		if quest == null: # just showing up in the middle doesn't do anything
			return
		if !quest.add_stone(id):
			quest.fail()
