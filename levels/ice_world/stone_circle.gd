extends Area3D

const _MAGIC_CRYSTAL: Item  = preload("uid://2lbwkp6ohqoq")

@export var id: int
@export var is_start_or_finish_point := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is not BogWitch:
		return
	var bw := body as BogWitch
	if Player.has_completed(BeaghmoreQuest.QUEST_NAME):
		return
	var quest: BeaghmoreQuest = bw.get_active_trial(BeaghmoreQuest.QUEST_NAME)
	if is_start_or_finish_point:
		if quest == null: # showing up at an end piece starts the quest
			quest = BeaghmoreQuest.new()
			quest.add_stone(id)
			bw.set_active_trial(BeaghmoreQuest.QUEST_NAME, quest)
		elif !quest.add_stone(id):
			quest.fail()
	else:
		if quest == null: # just showing up in the middle doesn't do anything
			return
		if !quest.add_stone(id):
			quest.fail()
	if quest.did_succeed():
		_succeed()

func _succeed() -> void:
	# TODO: play a little jingle
	for i in 3:
		var wi := _MAGIC_CRYSTAL.get_world_item()
		get_parent().add_child(wi)
		wi.global_position = global_position + Vector3(0.0, 2.5, 0.0)
		wi.plep(Vector3(0.0, 0.0, -3.0).rotated(Vector3.UP, (TAU * i) / 3.0))
