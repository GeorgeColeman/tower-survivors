class_name TowerWeaponArea
extends TowerWeapon


func _attack():
	super._attack()

	var all_targets = GameUtilities.get_all_targets_in_cells(_cells_in_range)

	if all_targets.size() == 0:
		return

	var hit_info = TowerWeaponHitInfo.new()

	hit_info.cells = _cells_in_range
	hit_info.mobs = all_targets

	_apply_on_hit_weapon_effects(hit_info)

	for target in all_targets:
		target.take_damage(DamageInfoFactory.new_damage_info(damage + _bonus_damage))

	# FIXME: we're using the projectile scene as an 'effect'
	if !projectile_scene:
		print_debug("No projectile scene")

		return

	var visual_effects = []

	for cell in _cells_in_range:
		var vfx = projectile_scene.instantiate()
		add_child(vfx)
		vfx.global_position = cell.scene_position
		visual_effects.append(vfx)

	get_tree().create_timer(1.0).timeout.connect(
		func():
			for effect in visual_effects:
				if !effect:
					continue

				effect.queue_free()
	)
