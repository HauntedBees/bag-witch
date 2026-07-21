class_name BeaghmoreQuest extends Quest

const QUEST_NAME := &"beaghmore"

const _RESET_TIME := 4.0
const _DETAIL_STRING := "Circles Remaining: %d\nTime Remaining: %s"

var _stones_touched: Array[int] = []
var _time_remaining := _RESET_TIME

func _init() -> void:
	super(QUEST_NAME)

func get_stones_touched() -> int:
	return _stones_touched.size()

func add_stone(id: int) -> bool:
	if _stones_touched.has(id):
		return false
	_stones_touched.append(id)
	_time_remaining = _RESET_TIME
	if _stones_touched.size() == 3:
		succeed()
	return true

func process(delta: float) -> void:
	_time_remaining -= delta
	_set_display_text()
	if _time_remaining <= 0.0:
		fail()

func _set_display_text_inner() -> void:
	var minutes := maxi(0, floori(_time_remaining / 60.0))
	var seconds := ceili(_time_remaining) % 60
	display.set_quest_text(_DETAIL_STRING % [
		3 - _stones_touched.size(),
		"%02d:%02d" % [minutes, seconds]
	])
