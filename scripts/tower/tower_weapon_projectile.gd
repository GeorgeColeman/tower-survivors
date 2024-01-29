class_name TowerWeaponProjectile
extends TowerWeapon


func _attack():
	super._attack()

	var multi_shot = _multi_shot_chance >= randf()
	var number_of_shots = 1 + _multi_shot_number_of_shots if multi_shot else 1

	var burst_shot_proc = _burst_shot_chance >= randf()
	var number_of_bursts = 1 + _burst_shot_number_of_shots if burst_shot_proc else 1

	var targets = GameUtilities.get_mob_targets_closest_to_main_tower(
		_cells_in_range,
		number_of_shots
	)

	var shoot = func(target: Mob):
		for shot in number_of_bursts:
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
	projectile.set_damage(damage + _bonus_damage)
	projectile.set_range(attack_range + _bonus_attack_range)
	projectile.set_speed(_data.projectile_speed * (1 + _projectile_speed_mod))
	projectile.set_pass(_projectile_pass)
	projectile.set_weapon_effects(weapon_effects)
