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

		passive_upgrade_data.id = section
		passive_upgrade_data.name = name
		passive_upgrade_data.texture = load(texture)
		passive_upgrade_data.ranks = _get_ranks(name, ranks)

		data.append(passive_upgrade_data)

	return data


static func _get_ranks(name, rank_data) -> Array[PassiveUpgrade.PassiveUpgradeRank]:
	var ranks: Array[PassiveUpgrade.PassiveUpgradeRank] = []
	var i: int = 0

	var effect_id: String = name

	for element in rank_data:
		var rank = PassiveUpgrade.PassiveUpgradeRank.new()

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
				"attack_speed_mod":
					_resolve_attack_speed_mod(rank, element[key])
				"burst_shot_number":
					_resolve_burst_shot_number(rank, element[key])
				"burst_shot_chance":
					_resolve_burst_shot_chance(rank, element[key])
				"projectile_speed":
					_resolve_projectile_speed(rank, element[key])
				"stasis_effect":
					_resolve_stasis_effect(effect_id, rank)
				"stasis_chance":
					_resolve_stasis_chance(effect_id, rank, element[key])
				"stasis_duration":
					_resolve_stasis_duration(effect_id, rank, element[key])
				"chill_effect":
					_resolve_chill_effect(effect_id, rank)
				"chill_factor":
					_resolve_chill_factor(effect_id, rank, element[key])
				"chill_duration":
					_resolve_chill_duration(effect_id, rank, element[key])
				"acid_effect":
					AcidEffectDataResolver._resolve_acid_effect(effect_id, rank)
				"acid_duration":
					AcidEffectDataResolver._resolve_acid_duration(effect_id, rank, element[key])
				"acid_damage":
					AcidEffectDataResolver._resolve_acid_damage(effect_id, rank, element[key])
				"crit_chance":
					_resolve_crit_chance(rank, element[key])
				_:
					print_debug("WARNING: unhandled rank key: %s" % key)

		# Remove the leading new line from rank description
		if rank.description.length() > 1:
			rank.description = rank.description.substr(1, rank.description.length())

		ranks.append(rank)

	return ranks


static func _resolve_multi_shot_number(rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s multi shot" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_multi_shot(variant)
	)


static func _resolve_multi_shot_chance(rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s%% multi shot chance" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_multi_shot_chance(variant)
	)


static func _resolve_attack_range(rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s attack range" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_bonus_attack_range(variant)
	)


static func _resolve_attack_speed(rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s attack speed" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_bonus_attack_speed(variant)
	)
	

static func _resolve_attack_speed_mod(rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s%% attack speed" % (variant * 100)
	
	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_attack_speed_mod(variant)
	)


static func _resolve_burst_shot_number(rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s burst shot" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_burst_shot(variant)
	)


static func _resolve_burst_shot_chance(rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s%% burst shot chance" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_burst_shot_chance(variant)
	)


static func _resolve_projectile_speed(rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s%% projectile speed" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_projectile_speed_mod(variant)
	)


static func _resolve_stasis_effect(effect_id: String, rank: PassiveUpgrade.PassiveUpgradeRank):
	rank.description += "\nAdds a stasis effect that has a chance to immobilise enemies"

	var stasis_effect = WeaponEffectStasis.new()

	rank.description += "\n%s" % stasis_effect.info

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_weapon_effect(effect_id, WeaponEffectStasis.new())
	)


static func _resolve_stasis_chance(effect_id: String, rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s%% stasis chance" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			var effect: WeaponEffectStasis = tower.tower_stats.try_get_weapon_effect(effect_id)

			effect.add_chance(variant)
	)


static func _resolve_stasis_duration(effect_id: String, rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s stasis duration" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			var effect: WeaponEffectStasis = tower.tower_stats.try_get_weapon_effect(effect_id)

			effect.add_duration(variant)
	)


static func _resolve_chill_effect(effect_id: String, rank: PassiveUpgrade.PassiveUpgradeRank):
	rank.description += "\nAdds a chill effect that slows enemies"

	var chill_effect = WeaponEffectChill.new()

	rank.description += "\n%s" % chill_effect.info

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_weapon_effect(effect_id, WeaponEffectChill.new())
	)


static func _resolve_chill_duration(effect_id: String, rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s chill duration" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			var effect: WeaponEffectChill = tower.tower_stats.try_get_weapon_effect(effect_id)

			effect.add_duration(variant)
	)


static func _resolve_chill_factor(effect_id: String, rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s%% chill strength" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			var effect: WeaponEffectChill = tower.tower_stats.try_get_weapon_effect(effect_id)

			effect.add_factor(variant)
	)


static func _resolve_crit_chance(rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s%% crit chance" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_crit_chance(variant)
	)
