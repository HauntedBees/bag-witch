extends Node3D

@onready var _player: BogWitch = %PlayerCharacter
@onready var _warp: WarpEffect = %WarpEffect
@onready var _world: Node3D = %WorldContainer

var _is_warping := false
var _current_loading_scene_path: String
var _current_loading_scene_destination: String

func _ready() -> void:
	SignalBus.load_new_level.connect(_on_load_new_level)

func _on_load_new_level(destination_uid: String, destination_point_name: String) -> void:
	if _is_warping:
		print("neuu!")
		return
	_warp.begin()
	get_tree().paused = true
	_is_warping = true
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
			_player.velocity = _player.velocity.rotated(Vector3.UP, w.global_rotation.y)
			_player.cam_holder.global_rotation.y = w.global_rotation.y
			_player.cam_holder.camera.global_rotation.x = w.global_rotation.x
			_player.global_position = w.global_position
			return

func _on_warp_effect_finished() -> void:
	get_tree().paused = false
