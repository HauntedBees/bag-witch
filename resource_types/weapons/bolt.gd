class_name Bolt extends Spell

func _inner_use(player: BogWitch) -> void:
	if _cached_scene == null:
		_cached_scene = load(projectile_path)
	var projectile: Projectile = _cached_scene.instantiate()
	player.get_parent().add_child(projectile)

	#var space_state := player.get_world_3d().direct_space_state
	#var query := PhysicsRayQueryParameters3D.create(player.global_position, player.get_front_direction() * 100.0, 5)
	#var result := space_state.intersect_ray(query)

	#if result.is_empty():
	#	return

	#projectile.global_position = result["position"]
	projectile.global_position = player.get_mouse_center()
	projectile.initialize(self, player.global_position)
