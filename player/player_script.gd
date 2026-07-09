class_name BogWitch extends PlayerCharacter

const _WEAPON_SLOTS: Array[StringName] = [
	&"weapon_slot_1", &"weapon_slot_2", &"weapon_slot_3", &"weapon_slot_4", &"weapon_slot_5",
	&"weapon_slot_6", &"weapon_slot_7", &"weapon_slot_8", &"weapon_slot_9", &"weapon_slot_0"
]


var current_weapon: Weapon

var _weapon_cooldown := 0.0

func _input(event: InputEvent) -> void:
	if _try_switch_weapon(event):
		return

func _process(delta: float) -> void:
	super(delta)
	_handle_attack(delta)

func _try_switch_weapon(event: InputEvent) -> bool:
	for i in _WEAPON_SLOTS.size():
		if GASInput.is_event_action_just_pressed(event, _WEAPON_SLOTS[i]):
			current_weapon = Player.data.get_weapon(i)
			print("current weapon is %s" % current_weapon)
			_weapon_cooldown = 0.0
			return true
	return false

func _handle_attack(delta: float) -> void:
	if _weapon_cooldown > 0.0:
		_weapon_cooldown -= delta
	if _weapon_cooldown > 0.0 || current_weapon == null || !Input.is_action_pressed(&"attack"):
		return
	print("pew pew")
	_weapon_cooldown = current_weapon.cooldown
