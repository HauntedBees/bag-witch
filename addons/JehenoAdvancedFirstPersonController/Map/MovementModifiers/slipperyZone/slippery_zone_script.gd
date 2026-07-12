extends Area3D

@export_range(0.0, 0.3, 0.01) var friction_multiplier : float = 0.1
@export_range(0.0, 1.0, 0.01) var acceleration_multiplier : float = 0.3

var play_char_body : PlayerCharacter

var original_values : Dictionary = {
	"accel" : 0.0,
	"deccel" : 0.0
}

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	if play_char_body:
		#apply acceleration and friction multiplier to acceleration values
		play_char_body.move_accel *= acceleration_multiplier
		play_char_body.move_deccel *= friction_multiplier
		play_char_body.idle_deccel *= friction_multiplier

func _on_body_entered(body) -> void:
	if body is PlayerCharacter:
		print("entering ice")
		play_char_body = body

		#stock original values
		original_values["accel"] = body.move_accel
		original_values["deccel"] = body.move_deccel
		original_values["ideccel"] = body.idle_deccel

func _on_body_exited(body) -> void:
	if body is PlayerCharacter:
		print("exiting ice")
		#return to original acceleration values
		body.move_accel = original_values["accel"]
		body.move_deccel = original_values["deccel"]
		body.idle_deccel = original_values["ideccel"]

		play_char_body = null
