extends MarginContainer

const _INFSYM := "∞"
const _COOLDOWN_MULT := 100.0

@onready var _equip_icon: SpellIcon = %EquipIcon
@onready var _current_amount: GASLabel = %CurrentAmount
@onready var _remaining_amount: GASLabel = %RemainingAmount
@onready var _cooldown_bar: ProgressBar = %CooldownBar

func _ready() -> void:
	Player.equip_changed.connect(_on_equip_changed)
	Player.weapon_cooldown_changed.connect(_on_weapon_cooldown_changed)
	Player.ammo_changed.connect(_on_ammo_changed)
	Player.data.inventory.item_added.connect(_on_item_changed)
	Player.data.inventory.item_removed.connect(_on_item_changed)
	_on_equip_changed(Player.data.current_equipped)

func _on_weapon_cooldown_changed(new_amount: float) -> void:
	_cooldown_bar.value = _cooldown_bar.max_value - new_amount * _COOLDOWN_MULT

func _on_equip_changed(id: InventoryDetail) -> void:
	if id == null:
		_equip_icon.visible = false
		_cooldown_bar.visible = false
		_current_amount.text = "-"
		_remaining_amount.text = ""
		return
	var w: Item = id.item
	_equip_icon.visible = true
	_equip_icon.spell = w
	_cooldown_bar.visible = true
	_cooldown_bar.max_value = w.usage_cooldown * _COOLDOWN_MULT
	_cooldown_bar.value = _cooldown_bar.max_value
	var ammo := Player.data.get_loaded_ammo(id)
	if ammo < 0:
		_current_amount.text = _INFSYM
		_remaining_amount.text = ""
	else:
		_current_amount.text = str(ammo)
		_remaining_amount.text = "/%d" % Player.data.get_remaining_ammo(w)

## Trigger refresh in case ammo was acquired.
func _on_item_changed(_i: InventoryDetail) -> void:
	_on_equip_changed(Player.data.current_equipped)

func _on_ammo_changed(new_amount: int) -> void:
	_current_amount.text = str(new_amount)
	_remaining_amount.text = "/%d" % Player.data.get_remaining_ammo(Player.data.current_equipped_item())
