class_name LazyAnim extends Node3D

var _anim: AnimationPlayer
var _looping_anim := &""

func set_anim(anim: StringName, looping := false, speed := 1.0) -> void:
	if _anim == null:
		_anim = get_child(1)
		_anim.animation_finished.connect(_on_anim_finished)
	if _anim == null:
		printerr("%s doesn't have an AnimationPlayer!" % name)
		return
	if !is_inside_tree():
		await ready
	_looping_anim = anim if looping else &""
	_anim.play(anim, -1.0, speed)

func _on_anim_finished(anim: StringName) -> void:
	if anim == _looping_anim:
		_anim.play(_looping_anim)
