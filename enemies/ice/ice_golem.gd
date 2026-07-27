extends EnemyDisplay

const _TINY := Vector3(0.01, 0.01, 0.01)

var _check_time := 0.25
var _melting := false
var _damage_to_add := 0.0
var _hit_weapon := Weapon.new()

@onready var _frost_golem: Node3D = %frost_golem
@onready var _smoke: GPUParticles3D = %Smoke2

func _ready() -> void:
	super()
	if get_tree().get_nodes_in_group(&"heat_world").size() > 0:
		_melting = true
		_smoke.emitting = true

func _process(delta: float) -> void:
	super(delta)
	_check_time -= delta
	if _check_time <= 0.0:
		_melting = get_tree().get_nodes_in_group(&"heat_world").size() > 0
		_smoke.emitting = _melting
		_check_time = 0.25
	if _melting:
		_frost_golem.scale = lerp(_frost_golem.scale, _TINY, 0.05 * delta)
		_damage_to_add += 4.0 * delta
		if _damage_to_add >= 1.0:
			var dmg := 3 * floori(_damage_to_add)
			_hit_weapon.damage_range = Vector2i(dmg, dmg + 2)
			receive_weapon_hit(Vector3.ZERO, _hit_weapon, false)
			_damage_to_add -= floorf(_damage_to_add)
