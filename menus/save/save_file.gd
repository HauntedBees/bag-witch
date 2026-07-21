class_name SaveFile extends Resource

@export var data: PlayerData
@export var image: Image
@export var slot: int

func _init(save_slot := -1, texture: Texture2D = null) -> void:
	if save_slot == -1: # default
		return
	data = Player.data.duplicate(true)
	image = texture.get_image()
	slot = save_slot
