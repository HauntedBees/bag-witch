class_name ProjectileWeapon extends Weapon

## The path to the projectile's scene.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var scene_path: String

## How fast it moves.
@export var velocity := 10.0

## How fast it's pulled downwards.
@export var gravity := 0.0

## How long it takes for the projectile to go away if it never hits anything.
@export var fade_time := 5.0

## Damage dealt.
@export var damage_range := Vector2i.ZERO

## How far back the enemy should be knocked when hit. Should be a big number.
@export var knockback := 0.0

## How far the enemy should be knocked up (ayy lmao) when hit. Should be a small number.
@export var additional_y_knockback := 0.0

## Various metadata properties can be increased by this attack.
@export var metadata_increase_ranges: Dictionary[BWEnum.Effect, Vector2] = {}

var _cached_scene: PackedScene = null

func _inner_use(player: BogWitch) -> void:
	if _cached_scene == null:
		_cached_scene = load(scene_path)
	var projectile: Projectile = _cached_scene.instantiate()
	player.get_parent().add_child(projectile)
	projectile.global_position = player.get_projectile_launch_point()
	projectile.look_at(player.get_mouse_center())
	projectile.initialize(self, player.global_position)
