extends AudioStreamPlayer

signal level_select_triggered()

const _LEVEL_SELECT_1: Array[StringName] = [
	&"inventory_up",
	&"inventory_down",
	&"inventory_left",
	&"inventory_right",
	&"action_pause"
]
const _LEVEL_SELECT_2: Array[StringName] = [
	&"play_char_move_forward_action",
	&"play_char_move_backward_action",
	&"play_char_move_left_action",
	&"play_char_move_right_action",
	&"action_pause"
]
const _FLIGHT_1: Array[StringName] = [
	&"inventory_up",
	&"inventory_up",
	&"inventory_down",
	&"inventory_down",
	&"inventory_up",
	&"inventory_up",
	&"inventory_up",
	&"inventory_up"
]
const _FLIGHT_2: Array[StringName] = [
	&"play_char_move_forward_action",
	&"play_char_move_forward_action",
	&"play_char_move_backward_action",
	&"play_char_move_backward_action",
	&"play_char_move_forward_action",
	&"play_char_move_forward_action",
	&"play_char_move_forward_action",
	&"play_char_move_forward_action"
]

var _level_select_idx := 0
var _flight_idx := 0

func _ready() -> void:
	volume_linear = Player.data.options.sound_volume
	Player.data.options.sound_volume_changed.connect(_on_sound_volume_changed)

func _on_sound_volume_changed(new_value: float) -> void:
	volume_linear = new_value

func _input(event: InputEvent) -> void:
	if !event.is_pressed():
		return
	if GASInput.is_event_action_just_pressed(event, _LEVEL_SELECT_1[_level_select_idx]) \
		|| GASInput.is_event_action_just_pressed(event, _LEVEL_SELECT_2[_level_select_idx]):
		_level_select_idx += 1
		if _level_select_idx >= _LEVEL_SELECT_1.size():
			play()
			level_select_triggered.emit()
			_level_select_idx = 0
	else:
		_level_select_idx = 0

	if GASInput.is_event_action_just_pressed(event, _FLIGHT_1[_flight_idx]) \
		|| GASInput.is_event_action_just_pressed(event, _FLIGHT_2[_flight_idx]):
		_flight_idx += 1
		if _flight_idx >= _FLIGHT_1.size():
			play()
			BWEnum.ALLOW_FLIGHT = true
			_flight_idx = 0
	else:
		_flight_idx = 0
