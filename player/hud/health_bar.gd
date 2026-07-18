extends TextureProgressBar

@onready var _health_count: GASLabel = %HealthCount

func _ready() -> void:
	max_value = Player.data.max_health
	value = Player.data.current_health
	_health_count.text = "%d/%d" % [value, max_value]
	Player.data.stat_changed.connect(_on_max_health_changed)
	Player.data.health_changed.connect(_on_health_changed)

func _on_max_health_changed() -> void:
	max_value = Player.data.max_health

func _on_health_changed(new_value: int) -> void:
	value = new_value
	_health_count.text = "%d/%d" % [new_value, max_value]
