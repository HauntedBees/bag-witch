class_name EnemyDisplay extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D

@export var animation_player: AnimationPlayer

var target: BogWitch

func _ready() -> void:
	if animation_player != null:
		animation_player.play(Anim.IDLE)
