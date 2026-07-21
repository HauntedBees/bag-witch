class_name SaveScreen extends CanvasLayer

const LAST_SAVED_DETAILS_PATH := "user://last_saved_details.tres"
const _COMPRESSED := false

signal closed()
signal load_save(sd: SaveFile)

@export var is_load := false

@export var active := true:
	set(value):
		active = value
		if !is_inside_tree():
			await ready
		visible = active
		if active && !is_load:
			_load_from_save_data()

@onready var _sels: Array[SaveOption] = [%SaveOption, %SaveOption2, %SaveOption3]

func _ready() -> void:
	for idx in _sels.size():
		var s := _sels[idx]
		if is_load:
			s.selected.connect(_on_load.bind(s))
		else:
			s.selected.connect(_on_save.bind(s, idx))
	if active || is_load:
		_load_from_save_data()

func _load_from_save_data() -> void:
	for idx in _sels.size():
		var s := _sels[idx]
		var path := get_save_path(idx)
		if FileAccess.file_exists(path):
			var file := ResourceLoader.load(path, "SaveFile", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
			s.set_from_save(file)

func _on_save(s: SaveOption, slot: int) -> void:
	var ui_nodes := get_tree().get_nodes_in_group(&"hud")
	var ui_nodes_to_restore: Array[CanvasLayer] = []
	for n: CanvasLayer in ui_nodes:
		if n.visible:
			ui_nodes_to_restore.append(n)
			n.visible = false
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var save_data := SaveFile.new(
		slot,
		get_viewport().get_texture()
	)
	for n: CanvasLayer in ui_nodes_to_restore:
		n.visible = true
	await get_tree().process_frame
	ResourceSaver.save(
		save_data,
		get_save_path(slot),
		ResourceSaver.FLAG_COMPRESS if _COMPRESSED else ResourceSaver.FLAG_NONE
	)
	s.set_from_save(save_data)
	var lsd := LastSaveDetails.new()
	lsd.slot = slot
	lsd.music_volume = save_data.data.options.music_volume
	lsd.sound_volume = save_data.data.options.sound_volume
	ResourceSaver.save(lsd, LAST_SAVED_DETAILS_PATH)

func _on_load(s: SaveOption) -> void:
	load_save.emit(s.save_data)

static func get_save_path(slot: int) -> String:
	return "user://save%d.%s" % [slot, "res" if _COMPRESSED else "tres"]

func _on_back_button_pressed() -> void:
	closed.emit()
