class_name ProjectileWeapon extends Weapon

## The path to the projectile's scene.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var scene_path: String

## How fast it moves.
@export var velocity := 10.0

## How fast it's pulled downwards.
@export var gravity := 0.0

## How long it takes for the projectile to go away if it never hits anything.
@export var fade_time := 5.0

var _cached_scene: PackedScene = null

func use(player: BogWitch) -> void:
	if _cached_scene == null:
		_cached_scene = load(scene_path)
	var projectile: Projectile = _cached_scene.instantiate()
	player.get_parent().add_child(projectile)
	projectile.global_position = player.get_projectile_launch_point()
	projectile.look_at(player.get_mouse_center())
	projectile.initialize(self)
