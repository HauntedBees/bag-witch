class_name PotionDisplay extends PanelContainer

var potion: Potion

@onready var _label: GASLabel = %GASLabel

func _process(_delta: float) -> void:
	if Player.data.active_potions.has(potion):
		_label.text = "%s (%ds)" % [potion.name, Player.data.active_potions[potion]]
