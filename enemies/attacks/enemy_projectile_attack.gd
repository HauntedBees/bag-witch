class_name EnemyProjectileAttack extends EnemyAttack

@export var velocity := 20.0
@export var lifespan := 10.0

var _time_remaining := 0.0

func _ready() -> void:
	_time_remaining = lifespan
	area.body_entered.connect(_on_body_entered)
	if flip_on_load:
		rotate_y(PI)

func _physics_process(delta: float) -> void:
	global_position -= transform.basis.z.normalized() * velocity * delta

func process(delta: float) -> void:
	_time_remaining -= delta
	if _time_remaining <= 0.0:
		queue_free()
