class_name InventoryItemDisplay extends Control

signal drag_ended()

const DRAG_OFFSET := Vector2(-32.0, -32.0)
const DRAG_OFFSET_ROTATED := Vector2(32.0, -32.0)

const _TILE_SIZE := 64.0
const _TOOLTIP_SCENE := preload("uid://bdcwnvc7nfxv3")

@export var details: InventoryDetail:
	set(value):
		if details != null && details.item is Ammo:
			(details.item as Ammo).ammo_updated.disconnect(_on_ammo_changed)
		details = value
		if details != null && details.item is Ammo:
			(details.item as Ammo).ammo_updated.connect(_on_ammo_changed)
		_update_display()

@onready var _equip_slot: InputImage = %EquipSlot
@onready var _item: TextureRect = %Item
@onready var _texture := _item.texture as AtlasTexture
@onready var _ammo_count: GASLabel = %AmmoCount

func _ready() -> void:
	_equip_slot.visible = false
	_ammo_count.visible = false

func _on_ammo_changed(new_amount: int) -> void:
	_ammo_count.text = str(new_amount)

func clear_slot() -> void:
	_equip_slot.visible = false

func set_slot(action_name: StringName) -> void:
	_equip_slot.visible = true
	_equip_slot.action_name = action_name

func _get_drag_data(_at_position: Vector2) -> Variant:
	var drag_icon := TextureRect.new()
	drag_icon.texture = _texture
	drag_icon.custom_minimum_size = _item.custom_minimum_size
	drag_icon.modulate.a = 0.5

	var preview = Control.new()
	preview.add_child(drag_icon)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if details.rotated:
		drag_icon.position = DRAG_OFFSET_ROTATED
		drag_icon.rotation_degrees = 90.0
	else:
		drag_icon.position = DRAG_OFFSET
	set_drag_preview(preview)

	var d := ItemDragDetails.new()
	d.item = details
	d.display = self
	d.preview = drag_icon
	return d

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_BEGIN:
			mouse_filter = Control.MOUSE_FILTER_IGNORE
			_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		NOTIFICATION_DRAG_END:
			mouse_filter = Control.MOUSE_FILTER_STOP
			_item.mouse_filter = Control.MOUSE_FILTER_PASS
			drag_ended.emit()

func _update_display() -> void:
	if details == null || details.item == null:
		visible = false
		return
	visible = true
	var item := details.item
	var item_size := _TILE_SIZE * item.icon.size
	custom_minimum_size = item_size
	_item.custom_minimum_size = item_size
	if details.rotated:
		custom_minimum_size = Vector2(item_size.y, item_size.x)
	tooltip_text = "placeholder"
	_texture.region = Rect2(
		_TILE_SIZE * item.icon.position,
		item_size
	)
	_item.rotation_degrees = 90.0 if details.rotated else 0.0
	if item is Ammo:
		_ammo_count.visible = true
		_ammo_count.text = str(item.get_amount())
	elif item is ProjectileWeapon && !(item as ProjectileWeapon).is_spell:
		_ammo_count.visible = true
		_ammo_count.text = str(details.ammo)
	else:
		_ammo_count.visible = false

func _make_custom_tooltip(_for_text: String) -> Object:
	var tt: ItemTooltip = _TOOLTIP_SCENE.instantiate()
	tt.item = details.item
	return tt
