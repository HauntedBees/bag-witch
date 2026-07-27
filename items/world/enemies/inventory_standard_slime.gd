extends InventoryStandardCharacter

@onready var _ice_cube: IceCube = %IceCube

var _check_time := 0.25
var _burn_time := 1.0

func _ready() -> void:
	super()
	if get_tree().get_nodes_in_group(&"ice_world").size() > 0:
		_ice_cube.visible = true

func _process(delta: float) -> void:
	_check_time -= delta
	if _check_time <= 0.0:
		_ice_cube.visible = get_tree().get_nodes_in_group(&"ice_world").size() > 0
		_check_time = 0.25
	if !_ice_cube.visible:
		_burn_time -= delta
		if _burn_time <= 0.0:
			_burn_time = 1.0
			SignalBus.take_damage_from_hands.emit(2)
