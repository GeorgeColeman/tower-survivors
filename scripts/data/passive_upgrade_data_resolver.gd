class_name PassiveUpgradeDataResolver
extends RefCounted


static func get_passive_upgrade_data() -> Array[PassiveUpgrade]:
	var data: Array[PassiveUpgrade] = []
	var config = ConfigFile.new()
	var err: Error = config.load("res://config/passive_upgrades.cfg")

	if err != OK:
		print_debug(err)

		return []

	for section in config.get_sections():
		var name = config.get_value(section, "name")
		var texture = config.get_value(section, "texture")
		var ranks = config.get_value(section, "ranks")

		var passive_upgrade_data = PassiveUpgrade.new()

		if !texture:
			texture = "res://sprites/missing.png"

		passive_upgrade_data.name = name
		passive_upgrade_data.texture = load(texture)
		passive_upgrade_data.ranks = _get_ranks(name, ranks)

		data.append(passive_upgrade_data)

	return data


static func _get_ranks(name, rank_data) -> Array[PassiveUpgrade.Rank]:
	var ranks: Array[PassiveUpgrade.Rank] = []
	var i: int = 0

	for element in rank_data:
		var rank = PassiveUpgrade.Rank.new()

		rank.number = i
		i += 1

		for key in element.keys():
			match key:
				"multi_shot_number":
					_resolve_multi_shot_number(rank, element[key])
				"multi_shot_chance":
					_resolve_multi_shot_chance(rank, element[key])
				"attack_range":
					_resolve_attack_range(rank, element[key])
				"attack_speed":
					_resolve_attack_speed(rank, element[key])
				"burst_shot_number":
					_resolve_burst_shot_number(rank, element[key])
				"burst_shot_chance":
					_resolve_burst_shot_chance(rank, element[key])
				"projectile_speed":
					_resolve_projectile_speed(rank, element[key])
				"stasis_chance":
					_resolve_stasis_chance(name, rank, element[key])
				"stasis_duration":
					_resolve_stasis_duration(name, rank, element[key])
				_:
					print_debug("WARNING: unhandled rank key: %s" % key)

		# Remove the leading new line from rank description
		if rank.description.length() > 1:
			rank.description = rank.description.substr(1, rank.description.length())

		ranks.append(rank)

	return ranks


static func _resolve_multi_shot_number(rank: PassiveUpgrade.Rank, variant):
	if !variant is int:
		print_debug("Multi shot number is not integer")

		return

	#rank.description += "\nIncreases the multi shot number of all towers by %s" % variant
	rank.description += "\n+%s multi shot" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_multi_shot(variant)
	)


static func _resolve_multi_shot_chance(rank: PassiveUpgrade.Rank, variant):
	if !variant is float:
		print_debug("Multi shot chance is not float")

		return

	#rank.description += "\nIncreases the multi shot chance of all towers by %s%%" % (variant * 100)
	rank.description += "\n+%s%% multi shot chance" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_multi_shot_chance(variant)
	)


static func _resolve_attack_range(rank: PassiveUpgrade.Rank, variant):
	if !variant is int:
		print_debug("Attack range is not integer")

		return

	rank.description += "\n+%s attack range" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_bonus_attack_range(variant)
	)


static func _resolve_attack_speed(rank: PassiveUpgrade.Rank, variant):
	if !variant is float:
		print_debug("Attack speed is not integer")

		return

	rank.description += "\n+%s attack speed" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_bonus_attack_speed(variant)
	)


static func _resolve_burst_shot_number(rank: PassiveUpgrade.Rank, variant):
	if !variant is int:
		print_debug("Burst shot number is not integer")

		return

	rank.description += "\n+%s burst shot" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_burst_shot(variant)
	)


static func _resolve_burst_shot_chance(rank: PassiveUpgrade.Rank, variant):
	if !variant is float:
		print_debug("Burst shot chance is not float")

		return

	rank.description += "\n+%s%% burst shot chance" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_burst_shot_chance(variant)
	)


static func _resolve_projectile_speed(rank: PassiveUpgrade.Rank, variant):
	if !variant is float:
		print_debug("projectile speed is not float")

		return

	rank.description += "\n+%s%% projectile speed" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_projectile_speed_mod(variant)
	)


static func _resolve_stasis_chance(name: String, rank: PassiveUpgrade.Rank, variant):
	rank.description += "\n+%s%% stasis chance" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			var effect: WeaponEffectStasis = tower.tower_stats.try_get_weapon_effect(name)

			if !effect:
				effect = WeaponEffectStasis.new()

				tower.tower_stats.add_weapon_effect(name, effect)

			effect.add_chance(variant)
	)


static func _resolve_stasis_duration(name: String, rank: PassiveUpgrade.Rank, variant):
	rank.description += "\n+%s stasis duration" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			var effect: WeaponEffectStasis = tower.tower_stats.try_get_weapon_effect(name)

			if !effect:
				effect = WeaponEffectStasis.new()

				tower.tower_stats.add_weapon_effect(name, effect)

			effect.add_duration(variant)
	)
