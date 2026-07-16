class_name ProjectileWeapon extends ReloadableItem

## The path to the projectile's scene.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var projectile_path: String

## How fast it moves.
@export var velocity := 10.0

## How fast it's pulled downwards.
@export var gravity := 0.0

## How long it takes for the projectile to go away if it never hits anything.
@export var fade_time := 5.0

var _cached_scene: PackedScene = null

func is_ammo_applicable() -> bool:
	return !is_spell

func _inner_use(player: BogWitch) -> void:
	if _cached_scene == null:
		_cached_scene = load(projectile_path)
	var projectile: Projectile = _cached_scene.instantiate()
	player.get_parent().add_child(projectile)
	if player.alt_hand_for_attack_anim && alt_use_animation != &"":
		projectile.global_position = player.get_projectile_launch_point(true)
	else:
		projectile.global_position = player.get_projectile_launch_point(false)
	projectile.look_at(player.get_mouse_center())
	projectile.initialize(self, player.global_position)
