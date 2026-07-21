class_name SaveOption extends MarginContainer

const _STATIC_FPS := 1.0 / 24.0
const _BORDER_COLOR := Color.YELLOW
const _BORDER_HIGHLIGHT_COLOR := Color.DARK_MAGENTA

signal selected()

var save_data: SaveFile

var _has_save := false
var _time_to_next_static := _STATIC_FPS

@onready var _game_screenshot: TextureRect = %GameScreenshot
@onready var _save_num: GASLabel = %SaveNum
@onready var _playtime: GASLabel = %Playtime
@onready var _mind: GASLabel = %Mind
@onready var _strength: GASLabel = %Strength
@onready var _magic: GASLabel = %Magic
@onready var _bag: GASLabel = %Bag
@onready var _speed: GASLabel = %Speed
@onready var _borders: Array[ColorRect] = [%ColorRect, %ColorRect2]

@onready var _default_tex: FastNoiseLite = (_game_screenshot.texture as NoiseTexture2D).noise

func set_from_save(sd: SaveFile) -> void:
	save_data = sd
	_has_save = true
	_save_num.text = "Save %d" % sd.slot
	_game_screenshot.texture = ImageTexture.create_from_image(sd.image)
	var minutes := floori(sd.data.playtime / 60.0)
	var seconds := floori(sd.data.playtime) % 60
	_set_text(_playtime, "Playtime: %02d:%02d" % [minutes, seconds])
	_set_text(_mind, "Mind: %d" % sd.data.mind)
	_set_text(_strength, "Strength: %d" % sd.data.strength)
	_set_text(_magic, "Magic: %d" % sd.data.magic)
	_set_text(_bag, "Bag: %d" % sd.data.bag)
	_set_text(_speed, "Speed: %d" % sd.data.speed)

func _process(delta: float) -> void:
	if _has_save:
		return
	_time_to_next_static -= delta
	if _time_to_next_static <= 0.0:
		_time_to_next_static += _STATIC_FPS
		_default_tex.seed = randi()

func _set_text(l: GASLabel, t: String) -> void:
	l.visible = true
	l.text = t

func _on_mouse_entered() -> void:
	for b in _borders:
		b.color = _BORDER_HIGHLIGHT_COLOR

func _on_mouse_exited() -> void:
	for b in _borders:
		b.color = _BORDER_COLOR

func _on_gui_input(event: InputEvent) -> void:
	if GASInput.is_click(event):
		selected.emit()
