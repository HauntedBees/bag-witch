extends VBoxContainer

const _QUEST_NOTICE_SCENE := preload("uid://0ant1xhdk6sn")

@export var player: BogWitch

func _ready() -> void:
	player.quest_added.connect(_on_quest_added)

func _on_quest_added(q: Quest) -> void:
	var qn: QuestNotice = _QUEST_NOTICE_SCENE.instantiate()
	q.display = qn
	add_child(qn)
