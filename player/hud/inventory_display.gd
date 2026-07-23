class_name InventoryDisplay extends VBoxContainer

signal inventory_toggled(shown: bool)
signal spawn_item(wi: WorldItem)

const _TILE_SCENE := preload("uid://chbbyih2rlm8q")
const _SAFE_TILE_SCENE := preload("uid://bydfttoq33xk3")
const _ITEM_SCENE := preload("uid://cdd6epqw6450l")
const _SPELL_SCENE := preload("uid://dd6i8p1qr32o4")
const _HIGHLIGHT_SCENE := preload("uid://8un54pjusa0y")
const _TIME_TO_TOOLTIP := 0.5
const _TOOLTIP_OFFSET := Vector2(32.0, 32.0)

var _item_grid_info: Dictionary[Vector2i, TileDetails] = {}

var _active := false
var _current_draggable: ItemDragDetails
var _highlighted_item: InventoryDetail
var _highlighted_spell: Weapon

var _tooltip_timer := 0.0

@onready var drop_text: GASLabel = %DropText

@onready var _highlight: Highlight = %Highlight
@onready var _tooltip_panel: TooltipPanel = %TooltipPanel

@onready var _mind_label: GASLabel = %MindLabel
@onready var _strength_label: GASLabel = %StrengthLabel
@onready var _magic_label: GASLabel = %MagicLabel
@onready var _bag_label: GASLabel = %BagLabel
@onready var _speed_label: GASLabel = %SpeedLabel

@onready var _drop_area: ItemDropArea = %DropArea
@onready var _drag_container: Control = %DragContainer

@onready var _item_grid: GridContainer = %ItemGridContainer
@onready var _items: Control = %ItemBucket
@onready var _inventory := Player.data.inventory

@onready var _spell_grid: GridContainer = %SpellGridContainer

func _ready() -> void:
	_draw_item_grid()
	_draw_spells()
	modulate.a = 0.0
	await get_tree().process_frame
	_draw_items()
	_inventory.item_added.connect(_on_item_added)
	_inventory.items_purged.connect(_on_items_purged)
	_drop_area.item_dropped.connect(_on_item_removed)
	Player.data.inventory.item_removed.connect(_on_item_removed_externally)
	Player.data.stat_changed.connect(_refresh_stats)
	_refresh_stats()

func _process(delta: float) -> void:
	if _highlighted_item == null && _highlighted_spell == null:
		return
	if _tooltip_timer <= 0.0:
		return
	_tooltip_timer -= delta
	if _tooltip_timer <= 0.0:
		var td := _item_grid_info[_highlight.grid_pos]
		_tooltip_panel.visible = true
		var id := td.item_display
		if id == null:
			if td.item == null:
				return
			id = _item_grid_info[td.item.position].item_display
		_tooltip_panel.global_position = id.global_position + _TOOLTIP_OFFSET
		_tooltip_panel.set_item(td.item)
		await get_tree().process_frame
		var x_end := _tooltip_panel.global_position.x + _tooltip_panel.size.x
		var rect := get_viewport_rect()
		if x_end > rect.size.x:
			var diff := x_end - rect.size.x
			_tooltip_panel.global_position.x -= diff

func _input(event: InputEvent) -> void:
	if Player.input_locked || !Player.inventory_available:
		return
	_toggle_inventory(event)
	if !_active:
		return
	_handle_keyboard_gamepad_input(event)
	_try_rotate_item(event)
	_try_equip_item(event)

func _handle_keyboard_gamepad_input(event: InputEvent) -> void:
	var dir := GASInput.get_vector2i_custom(
		event,
		&"inventory_left", &"inventory_right", &"inventory_up", &"inventory_down"
	)
	if dir != Vector2i.ZERO:
		var current_selected_item := _item_grid_info[_highlight.grid_pos].item
		var new_pos := _modulo_move_tile(_highlight.grid_pos, dir)
		if _current_draggable == null: # allow moving into same item if dragging something
			while current_selected_item != null \
				&& _item_grid_info[new_pos].item == current_selected_item \
				&& new_pos != _highlight.grid_pos:
				new_pos = _modulo_move_tile(new_pos, dir)
		_select_item_tile_by_position(new_pos, false)
		if _current_draggable:
			_on_potential_drag(_current_draggable, new_pos)
		return
	if GASInput.is_event_action_just_pressed(event, &"inventory_select"):
		if _current_draggable:
			_on_drag_dropped(_current_draggable, _highlight.grid_pos)
			_current_draggable.preview_parent.queue_free()
			_current_draggable = null
			get_viewport().gui_cancel_drag()
			_cleanup_highlights()
		else:
			var td := _item_grid_info[_highlight.grid_pos]
			var current_selected_item := td.item_display
			if current_selected_item == null:
				return #TODO: souuund
			var dd := current_selected_item.get_keyboard_gamepad_drag_data()
			_current_draggable = dd
			_drag_container.add_child(dd.preview_parent)
			_highlight.set_to_dragging_object(dd, td.tile)

func _try_rotate_item(event: InputEvent) -> void:
	if !GASInput.is_event_action_just_pressed(event, &"rotate_item"):
		return
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
	if !_current_draggable.from_mouse:
		_highlight.set_to_dragging_object(_current_draggable, null)

func _select_item_tile_by_position(v: Vector2i, from_mouse: bool) -> void:
	_tooltip_panel.visible = false
	var corner := _item_grid_info[v]
	if corner.item && _current_draggable == null:
		_select_item_tile(_item_grid_info[corner.item.position], from_mouse)
		if !from_mouse:
			_tooltip_timer = _TIME_TO_TOOLTIP
	else:
		_select_item_tile(corner, from_mouse)

func _modulo_move_tile(pos: Vector2i, dir: Vector2i) -> Vector2i:
	var new_pos := pos + dir
	return Vector2i(
		posmod(new_pos.x, Player.data.inventory.dimensions.x),
		posmod(new_pos.y, Player.data.inventory.dimensions.y)
	)

func _select_item_tile(t: TileDetails, use_mouse: bool) -> void:
	_tooltip_panel.visible = false
	_highlighted_item = t.item
	_highlight.set_to(t, use_mouse)
	if _current_draggable:
		_highlight.set_to_dragging_object(_current_draggable, t.tile)

func _select_empty_tile(tile: InventoryTile) -> void:
	_tooltip_panel.visible = false
	_highlighted_item = null
	_highlighted_spell = null
	_highlight.set_to_tile(tile)
	if _current_draggable:
		_highlight.set_to_dragging_object(_current_draggable, tile)

#region Refreshing
func is_open() -> bool:
	return _active

func _toggle_inventory(event: InputEvent) -> void:
	if !GASInput.is_event_action_just_pressed(event, &"toggle_inventory"):
		return
	_active = !_active
	_select_item_tile_by_position(Vector2i.ZERO, false)
	_tooltip_timer = 0.0
	modulate.a = 1.0 if _active else 0.0
	inventory_toggled.emit(_active)

func _refresh_stats() -> void:
	_mind_label.text = "Mind: %s" % Player.data.mind
	_strength_label.text = "Strength: %s" % Player.data.strength
	_magic_label.text = "Magic: %s" % Player.data.magic
	_bag_label.text = "Bag: %s" % Player.data.bag
	_speed_label.text = "Speed: %s" % Player.data.speed

func _on_item_added(i: InventoryDetail) -> void:
	_draw_item(i)
	_bake_item_positions()
	if i.item is Spellbook:
		_draw_spells()

func _on_items_purged() -> void:
	_draw_items()
	_draw_spells()
#endregion

#region Items
func _draw_item_grid() -> void:
	for i in _item_grid.get_children():
		i.queue_free()
	_item_grid_info.clear()
	_item_grid.columns = _inventory.dimensions.x
	for y in _inventory.dimensions.y:
		for x in _inventory.dimensions.x:
			var pos := Vector2i(x, y)
			var tile_scene := _SAFE_TILE_SCENE if _inventory.safe_tiles.has(pos) else _TILE_SCENE
			var tile: InventoryTile = tile_scene.instantiate()
			tile.grid_pos = pos
			tile.dragged_item_over.connect(_on_potential_drag)
			tile.dragged_item_dropped.connect(_on_drag_dropped)
			tile.mouse_entered.connect(_select_item_tile_by_position.bind(pos, true))
			_item_grid_info[pos] = TileDetails.new(tile)
			_item_grid.add_child(tile)

func _on_potential_drag(drag_details: ItemDragDetails, grid_pos: Vector2i) -> void:
	_current_draggable = drag_details
	_cleanup_highlights()
	var new_positions := drag_details.item.get_positions(grid_pos, _current_draggable.rotation_changed)
	if _can_place(drag_details.item, new_positions):
		for p in new_positions:
			_item_grid_info[p].tile.set_highlight(true)
	else:
		for p in new_positions:
			if _item_grid_info.has(p):
				_item_grid_info[p].tile.set_highlight(false)

func _cleanup_highlights() -> void:
	_drop_area.remove_highlight(false)
	for i: TileDetails in _item_grid_info.values():
		i.tile.remove_highlight()

func _on_drag_dropped(drag_details: ItemDragDetails, grid_pos: Vector2i) -> void:
	_drop_area.remove_highlight(true)
	var item := drag_details.item
	var new_positions := item.get_positions(grid_pos, _current_draggable.rotation_changed)
	if !_can_place(item, new_positions):
		print("no")
		return
	var potential_merge := _get_merge_item(item, new_positions)
	if potential_merge == null:
		var old_info := _item_grid_info[item.position]
		if old_info.item_display:
			old_info.item_display.queue_free()
			old_info.item_display = null
		item.position = grid_pos
		item.rotated = !item.rotated if _current_draggable.rotation_changed else item.rotated
		_draw_item(item)
		_bake_item_positions()
	else:
		potential_merge.item.combine(potential_merge, item)
		if Player.data.current_equipped == potential_merge:
			Player.equip_changed.emit(potential_merge)
		if item.item.is_destroyed_after_merge(item):
			var old_info := _item_grid_info[item.position]
			_inventory.remove_item(item)
			old_info.empty()
			_bake_item_positions()
		if potential_merge.item is Spellbook:
			_draw_spells()
		elif potential_merge.item is StatCrystal:
			var crystal: StatCrystal = potential_merge.item
			if crystal.is_ready(potential_merge):
				_use_crystal(crystal, potential_merge)
		if item.item.is_saw:
			Player.equip_changed.emit(Player.data.current_equipped)
			var old_info := _item_grid_info[potential_merge.position]
			old_info.item_display.queue_free()
			old_info.item_display = null
			_draw_item(potential_merge)
			_bake_item_positions()

func _try_equip_item(event: InputEvent) -> void:
	if _highlighted_item == null && _highlighted_spell == null:
		return
	for i in BWEnum.WEAPON_SLOTS.size():
		if GASInput.is_event_action_just_pressed(event, BWEnum.WEAPON_SLOTS[i]):
			if _highlighted_item != null:
				Player.data.equip_to_slot(_highlighted_item, i)
			else:
				Player.data.equip_spell_to_slot(_highlighted_spell, i)
			_bake_item_positions()
			_bake_spell_equips()
			return

func _use_crystal(crystal: StatCrystal, id: InventoryDetail) -> void:
	_inventory.remove_item(id)
	_bake_item_positions()
	crystal.activate(id)
	print("DEEDLE EEDLE EE")
	_refresh_stats()
	if crystal.stat == StatCrystal.Stat.Magic:
		_draw_spells()
	elif crystal.stat == StatCrystal.Stat.Bag:
		for i in _items.get_children():
			i.queue_free()
		_draw_item_grid()
		await get_tree().process_frame
	_draw_items()

func _on_item_tile_hovered(item: InventoryItemDisplay) -> void:
	_highlight.set_to_item(item, true)
	_highlighted_item = item.details
	_highlighted_spell = null

func _can_place(id: InventoryDetail, new_positions: Array[Vector2i]) -> bool:
	for p in new_positions:
		if _item_grid_info.has(p):
			var existing_id := _item_grid_info[p].item
			if existing_id == null || existing_id == id:
				continue
			if existing_id.item.can_be_combined(existing_id, id):
				continue
			if existing_id != id:
				return false
		else:
			return false
	return true

## Only call this AFTER [code]_can_place[/code] has returned [code]true[/code]
## already; this simply returns items that overlap, it does not check if the
## merge is compatible, and if that happens, well, this is a game jam, so I
## don't have time to double validate that shit. Just don't fuck it.
func _get_merge_item(item: InventoryDetail, new_positions: Array[Vector2i]) -> InventoryDetail:
	for p in new_positions:
		if _item_grid_info.has(p):
			var existing_item := _item_grid_info[p].item
			if existing_item == null || existing_item == item:
				continue
			if existing_item.item.can_be_combined(existing_item, item):
				return existing_item
	return null

func _on_item_removed_externally(id: InventoryDetail) -> void:
	for t: TileDetails in _item_grid_info.values():
		if t.item == id:
			t.empty()
	_bake_item_positions()

func _on_item_removed(i: ItemDragDetails) -> void:
	var id := i.item
	Player.data.inventory.remove_item(id)
	## _on_item_removed_externally handles the rest
	_select_item_tile_by_position(i.item.position, false)
	spawn_item.emit(id.item.get_world_item(id, true))
	if id.item is Spellbook:
		_draw_spells()

func _draw_items() -> void:
	for i in _items.get_children():
		i.queue_free()
	for i in _inventory.items:
		_draw_item(i)
	_bake_item_positions()

func _draw_item(i: InventoryDetail) -> void:
	var id: InventoryItemDisplay = _ITEM_SCENE.instantiate()
	_items.add_child(id)
	id.details = i
	id.drag_started.connect(_on_drag_started)
	id.drag_ended.connect(_on_drag_ended)
	id.mouse_entered.connect(_on_item_tile_hovered, CONNECT_APPEND_SOURCE_OBJECT)
	var info := _item_grid_info[i.position]
	id.global_position = info.tile.global_position
	info.item_display = id

func _on_drag_started() -> void:
	_drop_area.visible = true

func _on_drag_ended() -> void:
	if _current_draggable != null:
		_drop_area.remove_highlight(true)
		for i: TileDetails in _item_grid_info.values():
			i.tile.remove_highlight()
	_current_draggable = null
	_drop_area.visible = false

func _bake_item_positions() -> void:
	for t: TileDetails in _item_grid_info.values():
		t.item = null
	for i in _inventory.items:
		for p in i.get_positions(i.position):
			_item_grid_info[p].item = i
		var display := _item_grid_info[i.position].item_display
		if display == null:
			continue
		var equip_idx := Player.data.get_slot(i)
		if equip_idx < 0:
			display.clear_slot()
		elif equip_idx == 9:
			display.set_slot(&"weapon_slot_0")
		else:
			display.set_slot("weapon_slot_%d" % (equip_idx + 1))
#endregion

#region Spells
func _draw_spells() -> void:
	for c in _spell_grid.get_children():
		c.queue_free()
	var spells := Player.data.get_available_spells()
	var i := 0
	for y in 3:
		for x in 3:
			var pos := Vector2i(x, y)
			var tile: InventoryTile = _TILE_SCENE.instantiate()
			tile.mouse_entered.connect(_select_empty_tile, CONNECT_APPEND_SOURCE_OBJECT)
			tile.idx = i
			tile.grid_pos = pos
			_spell_grid.add_child(tile)
			if i < spells.size():
				var spell := spells[i]
				var si: SpellIcon = _SPELL_SCENE.instantiate()
				tile.add_child(si)
				tile.set_highlight(Player.data.has_spell(spell))
				si.spell = spell
				si.mouse_entered.connect(_on_spell_hovered, CONNECT_APPEND_SOURCE_OBJECT)
			i += 1
	_bake_spell_equips()

func _bake_spell_equips() -> void:
	for t: InventoryTile in _spell_grid.get_children():
		var display: SpellIcon = null
		for c: Node in t.get_children():
			if c is SpellIcon:
				display = c
				break
		if display == null:
			continue
		var equip_idx := Player.data.get_spell_slot(display.spell)
		if equip_idx < 0:
			display.clear_slot()
		elif equip_idx == 9:
			display.set_slot(&"weapon_slot_0")
		else:
			display.set_slot("weapon_slot_%d" % (equip_idx + 1))

func _on_spell_hovered(si: SpellIcon) -> void:
	_highlighted_item = null
	_highlighted_spell = si.spell
#endregion
