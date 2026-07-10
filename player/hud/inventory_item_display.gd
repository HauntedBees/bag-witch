class_name InventoryItemDisplay extends TextureRect

signal drag_ended()

const DRAG_OFFSET := Vector2(-32.0, -32.0)
const DRAG_OFFSET_ROTATED := Vector2(32.0, -32.0)

const _TILE_SIZE := 64.0
const _TOOLTIP_SCENE := preload("uid://bdcwnvc7nfxv3")

@export var details: InventoryDetail:
	set(value):
		details = value
		_update_display()

@onready var _texture := texture as AtlasTexture

func _get_drag_data(_at_position: Vector2) -> Variant:
	var drag_icon := TextureRect.new()
	drag_icon.texture = texture
	drag_icon.custom_minimum_size = custom_minimum_size
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
		NOTIFICATION_DRAG_END:
			mouse_filter = Control.MOUSE_FILTER_STOP
			drag_ended.emit()

func _update_display() -> void:
	if details == null || details.item == null:
		visible = false
		return
	visible = true
	var item := details.item
	var item_size := _TILE_SIZE * item.icon.size
	custom_minimum_size = item_size
	tooltip_text = "placeholder"
	_texture.region = Rect2(
		_TILE_SIZE * item.icon.position,
		item_size
	)
	rotation_degrees = 90.0 if details.rotated else 0.0
	# position is handled in InventoryDisplay

func _make_custom_tooltip(_for_text: String) -> Object:
	var tt: ItemTooltip = _TOOLTIP_SCENE.instantiate()
	tt.item = details.item
	return tt
