class_name EnemyDisplay extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D

@export var movement_speed := 5.0

var target: BogWitch
