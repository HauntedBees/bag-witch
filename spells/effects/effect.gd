class_name ClingingEffect extends Resource

signal finished()

var _player: BogWitch

func _init(player: BogWitch) -> void:
	_player = player

func physics_process(_delta: float) -> void:
	pass

func _finish() -> void:
	finished.emit()
