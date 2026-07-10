extends TextureProgressBar

func _ready() -> void:
	max_value = Player.data.max_health
	value = Player.data.current_health
	Player.health_changed.connect(_on_health_changed)

func _on_health_changed(new_value: int) -> void:
	value = new_value
