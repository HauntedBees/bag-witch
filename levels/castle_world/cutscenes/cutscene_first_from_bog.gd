extends Cutscene

const _KEYS: Array[String] = [
	"ok",
	"yousurvived?",
	"lolurold",
	"diehere",
	"peacebro",
	"whereami",
	"panic"
]

@export var queen: Node3D
@export var queen_anim: AnimationPlayer

var _state := 0

func _init_cutscene() -> void:
	Player.data.inventory.portal_wipe(true)
	Player.input_locked = true
	queen_anim.play(&"Use_Item")
	SignalBus.text_advanced.connect(_on_advanced_text)
	SignalBus.text_ended.connect(_on_text_ended)
	SignalBus.say_thing.emit("Queen Perpetua III", "Now, fetch those beasts unto... what's this?", _KEYS[0])
	SignalBus.say_thing.emit("Queen Perpetua III", "Thou were able to survive the portal?", _KEYS[1])
	SignalBus.say_thing.emit("Queen Perpetua III", "Yonder portal should have aged thee by a century... Nay, I suppose thou dost not appear a day over 600! Ha ha!", _KEYS[2])
	SignalBus.say_thing.emit("Queen Perpetua III", "No matter, thou shalt endure the remaining 600 in this prison.", _KEYS[3])
	SignalBus.say_thing.emit("Queen Perpetua III", "God be with you, traveler!", _KEYS[4])

func _additional_cleanup() -> void:
	Player.input_locked = false
	Player.inventory_available = true

func _on_advanced_text(new_key: String) -> void:
	match _KEYS.find(new_key):
		1:
			var t := create_tween()
			t.tween_property(queen, "rotation:y", PI / 2.0, 0.5)
		2:
			queen_anim.play(&"Taunt")
		3:
			queen_anim.play(&"Throw")
		4:
			var t := create_tween()
			t.tween_property(queen, "rotation:y", 0.0, 0.25)
			t.tween_callback(func() -> void:
				queen_anim.play(&"Walking_A")
			)
			t.tween_property(queen, "global_position:z", -58.0, 1.33)
			t.tween_property(queen, "global_position:z", 100.0, 0.25)

func _on_text_ended() -> void:
	match _state:
		0:
			Player.input_locked = false
			Player.inventory_available = true
			await get_tree().create_timer(1.0).timeout
			SignalBus.say_thing.emit("Bag Witch", "What happened...? I can barely remember anything! What happened to all of my things?! My bag is empty!!", _KEYS[5])
			SignalBus.say_thing.emit("Bag Witch", "This is bad... I need to find a way out of here!", _KEYS[6])
			_state += 1
