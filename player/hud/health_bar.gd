extends TextureProgressBar

@onready var _health_count: GASLabel = %HealthCount
@onready var _leaflet: InstancePlaceholder = %Leaflet

var _existing_lives: Array[Control] = []

func _ready() -> void:
	max_value = Player.data.max_health
	value = Player.data.current_health
	_health_count.text = "%d/%d" % [value, max_value]
	Player.data.stat_changed.connect(_on_max_health_changed)
	Player.data.health_changed.connect(_on_health_changed)
	Player.data.inventory.item_added.connect(_on_items_changed)
	Player.data.inventory.item_removed.connect(_on_items_changed)
	Player.data.inventory.items_purged.connect(_on_items_changed.bind(null))

func _on_max_health_changed() -> void:
	max_value = Player.data.max_health

func _on_health_changed(new_value: int) -> void:
	value = new_value
	_health_count.text = "%d/%d" % [new_value, max_value]

func _on_items_changed(_i: InventoryDetail) -> void:
	for l in _existing_lives:
		l.queue_free()
	_existing_lives.clear()
	var num_potions := 0
	for id in Player.data.inventory.items:
		if id.item is LifeRestoringPotion:
			num_potions += 1
	for i in num_potions:
		_existing_lives.append(_leaflet.create_instance())
