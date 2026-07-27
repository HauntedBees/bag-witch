extends InventoryStandardCharacter

const _TINY := Vector3(0.1, 0.1, 0.1)

var _check_time := 0.25

@onready var _smoke_cloud: SmokeCloud = %SmokeCloud

func _ready() -> void:
	super()
	if get_tree().get_nodes_in_group(&"heat_world").size() > 0:
		_smoke_cloud.visible = true

func _process(delta: float) -> void:
	_check_time -= delta
	if _check_time <= 0.0:
		_smoke_cloud.visible = get_tree().get_nodes_in_group(&"heat_world").size() > 0
		_check_time = 0.25
	if _smoke_cloud.visible:
		_character_container.scale = lerp(_character_container.scale, _TINY, 0.05 * delta)
