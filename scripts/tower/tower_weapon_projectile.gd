class_name TowerWeaponProjectile
extends TowerWeapon


func _attack():
	super._attack()

	var targets = GameUtilities.get_mob_targets_closest_to_main_tower(
		_cells_in_range,
		weapon_stats.get_multi_shot_number()
	)

	var shoot = func(target: Mob):
		for shot in weapon_stats.get_burst_shot_number():
			if !target:
				break

			_spawn_projectile_to_target(target)

			await get_tree().create_timer(0.1).timeout

	for target in targets:
		shoot.call(target)

	if targets.size() == 0 || !attack_sfx:
		return

	Audio.play_sfx(attack_sfx)


func _spawn_projectile_to_target(target: Mob):
	var projectile = projectile_scene.instantiate() as Projectile
	add_child(projectile)

	projectile.position = _firing_point
	projectile.set_target(target)
	projectile.set_range(weapon_stats.get_total_attack_range())
	projectile.set_speed(weapon_stats.get_total_projectile_speed())
	projectile.set_pass(_projectile_pass)
	projectile.set_weapon_effects(weapon_effects)

	projectile.get_damage = func() -> DamageInfo:
		return weapon_stats.get_calculated_damage()
