class_name TooltipPanel extends PanelContainer

@onready var _tooltip: ItemTooltip = %ItemTooltip

func set_item(id: InventoryDetail) -> void:
	_tooltip.item = id
