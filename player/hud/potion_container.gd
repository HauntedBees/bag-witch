extends VBoxContainer

const _POTION_DISPLAY_SCENE := preload("uid://b6iawfs8ct0do")

var _potions: Dictionary[Potion, PotionDisplay] = {}

func _ready() -> void:
	Player.data.potion_added.connect(_on_potion_added)
	Player.data.potion_removed.connect(_on_potion_removed)

func _on_potion_added(p: Potion) -> void:
	if _potions.has(p):
		_potions[p].queue_free()
	var pd: PotionDisplay = _POTION_DISPLAY_SCENE.instantiate()
	pd.potion = p
	add_child(pd)
	_potions[p] = pd

func _on_potion_removed(p: Potion) -> void:
	if _potions.has(p):
		_potions[p].queue_free()
		_potions.erase(p)
