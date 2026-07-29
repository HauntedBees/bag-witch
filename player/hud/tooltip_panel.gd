class_name TooltipPanel extends PanelContainer

@onready var _tooltip: ItemTooltip = %ItemTooltip

func set_item(id: InventoryDetail) -> void:
	_tooltip.item = id
	_tooltip.spell = null

func set_spell(id: Spell) -> void:
	_tooltip.spell = id
	_tooltip.item = null
