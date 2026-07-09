class_name InventoryDisplay extends Control

signal inventory_toggled(shown: bool)

const _TILE_SCENE := preload("uid://chbbyih2rlm8q")
const _ITEM_SCENE := preload("uid://cdd6epqw6450l")

var _inventory := Inventory.new()
var _grid_info: Dictionary[Vector2i, TileDetails] = {}

var _active := false
var _current_draggable: ItemDragDetails

@onready var _grid: GridContainer = %GridContainer
@onready var _items: Control = %ItemBucket

func _ready() -> void:
	_grid.columns = _inventory.dimensions.x
	for y in _inventory.dimensions.y:
		for x in _inventory.dimensions.x:
			var pos := Vector2i(x, y)
			var tile: InventoryTile = _TILE_SCENE.instantiate()
			tile.grid_pos = pos
			tile.item_dropped.connect(_on_item_dropped)
			tile.item_hovered.connect(_on_item_hovered)
			_grid_info[pos] = TileDetails.new(tile)
			_grid.add_child(tile)
	modulate.a = 0.0
	await get_tree().process_frame
	_draw_items()
	_inventory.item_added.connect(_draw_item)

func _input(event: InputEvent) -> void:
	if GASInput.is_event_action_just_pressed(event, &"toggle_inventory"):
		_active = !_active
		modulate.a = 1.0 if _active else 0.0
		inventory_toggled.emit(_active)
	if GASInput.is_event_action_just_pressed(event, &"rotate_item"):
		if _current_draggable == null:
			return
		_current_draggable.rotation_changed = !_current_draggable.rotation_changed
		var rotated := _current_draggable.item.rotated != _current_draggable.rotation_changed
		if rotated:
			_current_draggable.preview.rotation_degrees = 90.0
			_current_draggable.preview.position = InventoryItemDisplay.DRAG_OFFSET_ROTATED
		else:
			_current_draggable.preview.rotation_degrees = 0.0
			_current_draggable.preview.position = InventoryItemDisplay.DRAG_OFFSET


func _on_item_hovered(drag_details: ItemDragDetails, grid_pos: Vector2i) -> void:
	_current_draggable = drag_details
	for i: TileDetails in _grid_info.values():
		i.tile.remove_highlight()
	var new_positions := drag_details.item.get_positions(grid_pos, _current_draggable.rotation_changed)
	if _can_place(drag_details.item, new_positions):
		for p in new_positions:
			_grid_info[p].tile.set_highlight(true)
	else:
		for p in new_positions:
			if _grid_info.has(p):
				_grid_info[p].tile.set_highlight(false)

func _on_item_dropped(drag_details: ItemDragDetails, grid_pos: Vector2i) -> void:
	var item := drag_details.item
	var new_positions := item.get_positions(grid_pos, _current_draggable.rotation_changed)
	if _can_place(item, new_positions):
		var old_info := _grid_info[item.position]
		old_info.item_display.queue_free()
		old_info.item_display = null
		item.position = grid_pos
		item.rotated = !item.rotated if _current_draggable.rotation_changed else item.rotated
		_draw_item(item)
		_bake_positions()
	else:
		print("no")

func _can_place(item: InventoryDetail, new_positions: Array[Vector2i]) -> bool:
	for p in new_positions:
		if _grid_info.has(p):
			var existing_item := _grid_info[p].item
			if existing_item != null && existing_item != item:
				return false
		else:
			return false
	return true

func _draw_items() -> void:
	for i in _items.get_children():
		i.queue_free()
	for i in _inventory.items:
		_draw_item(i)
	_bake_positions()

func _draw_item(i: InventoryDetail) -> void:
	var id: InventoryItemDisplay = _ITEM_SCENE.instantiate()
	_items.add_child(id)
	id.details = i
	id.drag_ended.connect(_on_drag_ended)
	var info := _grid_info[i.position]
	id.global_position = info.tile.global_position
	if i.rotated:
		id.global_position += Vector2(64.0, 0.0)
	info.item_display = id

func _on_drag_ended() -> void:
	if _current_draggable != null:
		for i: TileDetails in _grid_info.values():
			i.tile.remove_highlight()
	_current_draggable = null

func _bake_positions() -> void:
	for t: TileDetails in _grid_info.values():
		t.item = null
	for i in _inventory.items:
		for p in i.get_positions(i.position):
			_grid_info[p].item = i

class TileDetails extends RefCounted:
	var tile: InventoryTile
	var item: InventoryDetail
	var item_display: InventoryItemDisplay
	func _init(t: InventoryTile) -> void:
		tile = t
