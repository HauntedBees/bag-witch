class_name Throwable extends Weapon

const _VELOCITY := 60.0

## The object that actually gets thrown.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var throwable_scene_path: String

@export var explodes_on_impact := true

func _inner_use(player: BogWitch) -> void:
	var projectile: ThrownObject = load(throwable_scene_path).instantiate()
	projectile.weapon = self
	player.get_parent().add_child(projectile)
	projectile.global_position = player.get_projectile_launch_point(false) + Vector3(0.0, 0.5, 0.0)
	var pos := player.get_mouse_center()
	projectile.look_at(pos)
	projectile.linear_velocity = (pos - projectile.global_position).normalized() *_VELOCITY
