class_name Cleric extends EnemyDisplay

@export var sabbath_actions: Array[Node] = []

func _ready() -> void:
	super()
	var weekday: int = Time.get_datetime_dict_from_system()["weekday"]
	if weekday == Time.WEEKDAY_SUNDAY:
		for n in sabbath_actions:
			n.queue_free()
