class_name TheBoss extends Node3D

signal on_died()

@export var pf: PathFollow3D

var _active := false
var _in_anim := false
var _time_to_next := 6.0
var _rotate_speed := 10.0

@onready var anim: AnimationPlayer = $clanker_boss/AnimationPlayer
@onready var audio: GASAudioStreamPlayer3D = $GASAudioStreamPlayer3D
@onready var _queen: EnemyDisplay = $"clanker_boss/Rig/Skeleton3D/B-Head/QueenSpot/QueenPerpetuaXII"

func _ready() -> void:
	_queen.alive_collider.disabled = true

func _process(delta: float) -> void:
	if !_active || _in_anim:
		return
	_time_to_next -= delta
	if _time_to_next <= 0.0:
		_in_anim = true
		_time_to_next = randf_range(0.0, 10.0)
		var speed := randf_range(0.25, 1.5)
		match randi_range(0, 3):
			0: anim.play(&"Bot_PunchR", -1.0, speed)
			1: anim.play(&"Bot_PunchL", -1.0, speed)
			2: anim.play(&"Bot_Smash", -1.0, speed)
			3: anim.play(&"Bot_Spin", -1.0, speed)

func _physics_process(delta: float) -> void:
	if !_active || _in_anim:
		return
	pf.progress += _rotate_speed * delta

func poof() -> void:
	anim.play(&"Spawn_Ground")
	anim.animation_finished.connect(_on_anim_finished)
	audio.play()

func _on_anim_finished(n: StringName) -> void:
	_in_anim = false
	if n != &"Bot_Idle":
		anim.play(&"Bot_Idle")

func show_queen() -> void:
	_queen.visible = true
	_queen.animation_player.play(&"Spawn_Ground")
	_queen.alive_collider.disabled = false

func activate() -> void:
	_active = true

func _on_queen_perpetua_xii_on_hit(_w: Weapon, _dir: Vector3, _damage_dealt: int, _impact_position: Vector3, _sneak_attack: bool) -> void:
	_rotate_speed = 10.0 + 20.0 * (1.0 - (float(_queen.health) / _queen.max_health))

func _on_queen_perpetua_xii_on_died() -> void:
	_active = false
	on_died.emit()
