class_name ItemSelect extends VBoxContainer

const _OK_POS := Vector2.ZERO
const _NO_POS := Vector2(16.0, 0.0)

@onready var _selection: VBoxContainer = %Selection
@onready var _item_name: GASLabel = %ItemName
@onready var _input_image: InputImage = %InputImage
@onready var _grab_icon: TextureRect = %GrabIcon
@onready var _grab_atlas: AtlasTexture = _grab_icon.texture

func set_from_world_item(w: WorldItem) -> void:
	_set_visible(w.get_screen_bounds(), w.get_item_name(), true)
	_grab_icon.visible = true
	var can_hold := Player.data.inventory.get_item_if_fits(w.item)
	_grab_atlas.region.position = _OK_POS if can_hold else _NO_POS

func set_from_enemy(e: EnemyDisplay) -> void:
	var can_grab := Player.data.strength >= e.capture_level
	_set_visible(e.get_screen_bounds(), e.enemy_name, can_grab)
	if can_grab:
		_grab_icon.visible = true
		var can_hold := Player.data.inventory.get_item_if_fits(e.suck_drop)
		_grab_atlas.region.position = _OK_POS if can_hold else _NO_POS
	else:
		_grab_icon.visible = false

func _set_visible(dims: Rect2, display_name: String, show_input_image: bool) -> void:
	visible = true
	_selection.custom_minimum_size = dims.size
	_item_name.text = display_name
	_input_image.visible = show_input_image
