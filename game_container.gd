class_name GameContainer extends Node3D

const _GAME_OVER_SOUND := preload("uid://bnj7gqfldkufl")

var is_loading_from_file := false

@onready var _audio_manager: AudioManager = %AudioManager
@onready var _player: BogWitch = %PlayerCharacter
@onready var _warp: WarpEffect = %WarpEffect
@onready var _world: Node3D = %WorldContainer

var _is_warping := false
var _current_loading_scene_path: String
var _current_loading_scene_destination: String

func _ready() -> void:
	SignalBus.load_new_level.connect(_on_load_new_level)
	SignalBus.game_over.connect(_on_game_over)
	if !is_loading_from_file:
		var b: PackedScene = load("uid://b8ihm5mdma5nd")
		set_from_save(b.instantiate(), "TestPoint")

func set_from_save(world: Node3D, warp_pos: String) -> void:
	if !is_inside_tree():
		await ready
	_current_loading_scene_destination = warp_pos
	_world.add_child(world)
	_place_player.call_deferred()

func _on_game_over() -> void:
	_warp.begin()
	get_tree().paused = true
	_is_warping = true
	Player.data.death_wipe()
	await _audio_manager.fade_out_music()
	_audio_manager.silence_all_sounds()
	_audio_manager.play_sound(_GAME_OVER_SOUND)
	await get_tree().create_timer(_GAME_OVER_SOUND.get_length() - 0.5).timeout
	Player.data.current_health = roundi(Player.data.max_health * 0.6)
	_load_level_inner(
		"uid://ssp37cocp7km", # Bog World
		"FromDeath"
	)

func _on_load_new_level(destination_uid: String, destination_point_name: String) -> void:
	if _is_warping:
		print("neuu!")
		return
	_warp.begin()
	get_tree().paused = true
	_is_warping = true
	Player.data.last_warped_scene_uid = destination_uid
	Player.data.last_warped_warp_point_name = destination_point_name
	_load_level_inner(destination_uid, destination_point_name)

func _load_level_inner(destination_uid: String, destination_point_name: String) -> void:
	_current_loading_scene_path = ResourceUID.uid_to_path(destination_uid)
	print("loading %s" % _current_loading_scene_path)
	ResourceLoader.load_threaded_request(_current_loading_scene_path, "PackedScene", true)
	_current_loading_scene_destination = destination_point_name

func _process(_delta: float) -> void:
	if !_is_warping:
		return
	var status := ResourceLoader.load_threaded_get_status(_current_loading_scene_path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		for w in _world.get_children():
			w.queue_free()
		var loaded_scene: PackedScene = ResourceLoader.load_threaded_get(_current_loading_scene_path)
		var new_level: Node3D = loaded_scene.instantiate()
		_world.add_child(new_level)
		_place_player.call_deferred()
		_is_warping = false
		_warp.end()

func _place_player() -> void:
	var warps := get_tree().get_nodes_in_group(&"warp")
	for w: WarpPoint in warps:
		if w.name == _current_loading_scene_destination:
			await get_tree().process_frame
			_player.velocity = _player.velocity.rotated(Vector3.UP, w.global_rotation.y - _player.cam_holder.global_rotation.y)
			_player.velocity *= w.velocity_multiplier
			_player.velocity.y = 0.0
			_player.cam_holder.global_rotation.y = w.global_rotation.y
			_player.cam_holder.camera.global_rotation.x = w.global_rotation.x
			_player.global_position = w.global_position
			return

func _on_warp_effect_finished() -> void:
	get_tree().paused = false
