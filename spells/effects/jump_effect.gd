class_name JumpEffect extends ClingingEffect

var _y_velocity := 0.0
var _time_remaining := 0.0

func _init(player: BogWitch, y_velocity: float, duration: float) -> void:
	super(player)
	_y_velocity = y_velocity
	_time_remaining = duration

func physics_process(delta: float) -> void:
	var orig_y := _player.velocity.y
	_player.velocity = _player.velocity.normalized() * 0.25
	if _time_remaining <= 0:
		_player.velocity.y = orig_y
		if _player.is_on_floor():
			_finish()
	else:
		_player.velocity.y = _y_velocity
		_time_remaining -= delta
