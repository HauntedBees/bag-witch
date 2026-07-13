class_name EnemyAlertFriends extends EnemyBehavior

@export var radius := 20.0

var _alert_timeout := 0.0

func _setup_behavior() -> void:
	_parent.on_hit.connect(_on_hit)

func _on_hit(_w: Weapon, _source: Vector3, _damage_dealt: int) -> void:
	_alert_timeout = 5.0

func _permanent_behave(delta: float) -> void:
	if _alert_timeout > 0.0:
		if _parent.target != null:
			get_tree().call_group(&"enemy", &"_on_peer_called_for_help", _parent.target, _parent.global_position, radius)
			_alert_timeout = 0.0
		else:
			_alert_timeout -= delta
