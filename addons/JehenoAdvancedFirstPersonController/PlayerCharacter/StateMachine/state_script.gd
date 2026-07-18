extends Node

class_name State

signal transitioned #it's normal if this signal isn't used in this script, because it's purpose is to be used in the scripts that extends from the State class

func enter(_char_reference : CharacterBody3D):
	#enter state
	pass

func exit():
	#exit state
	pass

func update(_delta : float):
	#process update
	pass

func physics_update(_delta : float):
	#physics_process update
	pass

func _get_movement_vector(play_char: PlayerCharacter) -> Vector2:
	if Player.input_locked:
		return Vector2.ZERO
	return Input.get_vector(play_char.move_left_action, play_char.move_right_action, play_char.move_forward_action, play_char.move_backward_action)
