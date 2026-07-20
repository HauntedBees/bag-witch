extends TextureRect

const _TIME_PER_FRAME := 0.25
const _X_OFFSET := 173.0

var _time_elapsed := _TIME_PER_FRAME
var _flipped := false

@onready var _tex := texture as AtlasTexture

func _process(delta: float) -> void:
	_time_elapsed -= delta
	if _time_elapsed <= 0.0:
		_time_elapsed += _TIME_PER_FRAME
		_flipped = !_flipped
		_tex.region.position.x = _X_OFFSET if _flipped else 0.0
