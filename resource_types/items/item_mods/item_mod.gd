class_name ItemMod extends Item

@export var mod_name: StringName

@export var connects_to: Item

@export_range(1, 3) var mind_requirement := 1

func get_description(_id: InventoryDetail) -> String:
	if Player.data.mind < mind_requirement:
		return "If my Mind stat were higher I might know how to use this..."
	return description
