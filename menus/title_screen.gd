class_name TitleScreen extends Control

const _GAME_PATH := "res://game_container.tscn"
const _MUSIC_FADE_RATE := 0.25

var _is_loading_game := false
var _level_scene_path: String
var _game_scene: PackedScene = null
var _level_scene: PackedScene = null
var _btn_idx := 0

@onready var _continue_btn: TextureButton = %Continue
@onready var _title_music: AudioStreamPlayer = %TitleMusic
@onready var _controls_list: CanvasLayer = %ControlsList
@onready var _options_menu: OptionsMenu = %OptionsMenu
@onready var _save_screen: SaveScreen = %SaveScreen
@onready var _credits_menu: CreditsMenu = %CreditsMenu
@onready var _fade_player: AnimationPlayer = %FadePlayer
@onready var _buttons: Array[TextureButton] = [%NewGame, %Continue, %Controls,  %Options, %Credits]

func _ready() -> void:
	var last_data: LastSaveDetails = null
	if FileAccess.file_exists(SaveScreen.LAST_SAVED_DETAILS_PATH):
		last_data = ResourceLoader.load(SaveScreen.LAST_SAVED_DETAILS_PATH, "LastSaveDetails", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
		Player.data.options.music_volume = last_data.music_volume
		Player.data.options.sound_volume = last_data.sound_volume
	else:
		_buttons.erase(_continue_btn)
	_continue_btn.visible = last_data != null
	_title_music.volume_linear = Player.data.options.music_volume
	Player.data.options.music_volume_changed.connect(_on_music_volume_changed)
	for b in _buttons:
		b.mouse_entered.connect(_on_button_hovered, CONNECT_APPEND_SOURCE_OBJECT)
	_buttons[0].mouse_entered.emit.call_deferred()

func _unhandled_input(event: InputEvent) -> void:
	if BWEnum.is_menu_action_pressed(event):
		_buttons[_btn_idx].pressed.emit()
		return
	var dir := BWEnum.get_input_dir(event)
	if dir == Vector2i.ZERO || dir.x == 0:
		return
	var next_btn := posmod(_btn_idx + dir.x, _buttons.size())
	_buttons[next_btn].mouse_entered.emit()

func _on_button_hovered(b: TextureButton) -> void:
	_btn_idx = _buttons.find(b)

func _on_music_volume_changed(new_value: float) -> void:
	if _is_loading_game:
		return
	_title_music.volume_linear = new_value

func _on_options_pressed() -> void:
	if _is_loading_game:
		return
	_options_menu.active = true
	SignalBus.ui_confirm.emit()

func _on_credits_pressed() -> void:
	if _is_loading_game:
		return
	_credits_menu.active = true
	SignalBus.ui_confirm.emit()

func _on_credits_menu_closed() -> void:
	if _is_loading_game:
		return
	_credits_menu.active = false
	_buttons[3].mouse_entered.emit()
	SignalBus.ui_back.emit()

func _on_options_menu_closed() -> void:
	if _is_loading_game:
		return
	_options_menu.active = false
	_buttons[2].mouse_entered.emit()
	SignalBus.ui_back.emit()

func _on_continue_pressed() -> void:
	if _is_loading_game:
		return
	_save_screen.active = true
	SignalBus.ui_confirm.emit()

func _on_save_screen_closed() -> void:
	if _is_loading_game:
		return
	_save_screen.active = false
	_buttons[1].mouse_entered.emit()
	SignalBus.ui_back.emit()

func _on_new_game_pressed() -> void:
	if _is_loading_game:
		return
	SignalBus.ui_confirm.emit()
	_load_game()

func _on_controls_pressed() -> void:
	if _is_loading_game:
		return
	SignalBus.ui_confirm.emit()
	_controls_list.visible = true

func _on_save_screen_load_save(sd: SaveFile) -> void:
	if _is_loading_game:
		return
	Player.data = sd.data
	SignalBus.ui_confirm.emit()
	_load_game()

func _load_game() -> void:
	ResourceLoader.load_threaded_request(_GAME_PATH, "PackedScene", true)
	_level_scene_path = ResourceUID.uid_to_path(Player.data.last_warped_scene_uid)
	ResourceLoader.load_threaded_request(_level_scene_path, "PackedScene", true)
	_is_loading_game = true
	_fade_player.play(&"FadeToBlack")

func _process(delta: float) -> void:
	if !_is_loading_game:
		return
	_title_music.volume_linear = maxf(0.0, _title_music.volume_linear - delta * _MUSIC_FADE_RATE)
	var game_status := ResourceLoader.load_threaded_get_status(_GAME_PATH)
	if game_status == ResourceLoader.THREAD_LOAD_LOADED:
		_game_scene = ResourceLoader.load_threaded_get(_GAME_PATH)
	var level_status := ResourceLoader.load_threaded_get_status(_level_scene_path)
	if level_status == ResourceLoader.THREAD_LOAD_LOADED:
		_level_scene = ResourceLoader.load_threaded_get(_level_scene_path)
	if _game_scene != null && _level_scene != null:
		var game_container: GameContainer = _game_scene.instantiate()
		if !OS.has_feature("dev"):
			var level: Node3D = _level_scene.instantiate()
			game_container.is_loading_from_file = true
			get_tree().change_scene_to_node(game_container)
			game_container.set_from_save(level, Player.data.last_warped_warp_point_name)
		else:
			get_tree().change_scene_to_node(game_container)

func _on_button_mouse_entered() -> void:
	SignalBus.ui_cursor.emit()

func _on_cheat_code_manager_level_select_triggered() -> void:
	Player.data.last_warped_scene_uid = "uid://x0dsvspu5lqf"
	Player.data.last_warped_warp_point_name = "LevelSelectPoint"
	SignalBus.ui_confirm.emit()
	_load_game()
