class_name TitleScreen extends Control

const _GAME_PATH := "res://game_container.tscn"
const _MUSIC_FADE_RATE := 0.25

var _is_loading_game := false
var _level_scene_path: String
var _game_scene: PackedScene = null
var _level_scene: PackedScene = null

@onready var _continue_btn: TextureButton = %Continue
@onready var _title_music: AudioStreamPlayer = %TitleMusic
@onready var _options_menu: OptionsMenu = %OptionsMenu
@onready var _save_screen: SaveScreen = %SaveScreen
@onready var _fade_player: AnimationPlayer = %FadePlayer

func _ready() -> void:
	var last_data: LastSaveDetails = null
	if FileAccess.file_exists(SaveScreen.LAST_SAVED_DETAILS_PATH):
		last_data = ResourceLoader.load(SaveScreen.LAST_SAVED_DETAILS_PATH, "LastSaveDetails", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
		Player.data.options.music_volume = last_data.music_volume
		Player.data.options.sound_volume = last_data.sound_volume
	_continue_btn.visible = last_data != null
	_title_music.volume_linear = Player.data.options.music_volume
	Player.data.options.music_volume_changed.connect(_on_music_volume_changed)
	_title_music.play()

func _on_music_volume_changed(new_value: float) -> void:
	if _is_loading_game:
		return
	_title_music.volume_linear = new_value

func _on_options_pressed() -> void:
	if _is_loading_game:
		return
	_options_menu.active = true

func _on_options_menu_closed() -> void:
	if _is_loading_game:
		return
	_options_menu.active = false

func _on_continue_pressed() -> void:
	if _is_loading_game:
		return
	_save_screen.active = true

func _on_save_screen_closed() -> void:
	if _is_loading_game:
		return
	_save_screen.active = false

func _on_new_game_pressed() -> void:
	if _is_loading_game:
		return
	_load_game()

func _on_save_screen_load_save(sd: SaveFile) -> void:
	if _is_loading_game:
		return
	Player.data = sd.data
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
		game_container.is_loading_from_file = true
		var level: Node3D = _level_scene.instantiate()
		get_tree().change_scene_to_node(game_container)
		game_container.set_from_save(level, Player.data.last_warped_warp_point_name)
