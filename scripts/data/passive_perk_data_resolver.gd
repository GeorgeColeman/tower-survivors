class_name PassivePerkDataResolver
extends RefCounted


static func get_passive_perk_data() -> Array[PassivePerk]:
	var data: Array[PassivePerk] = []
	var config = ConfigFile.new()
	var err = config.load("res://config/passive_perks.cfg")

	if err != OK:
		return []

	for section in config.get_sections():
		var name = config.get_value(section, "name")
		var texture = config.get_value(section, "texture")
		var ranks = config.get_value(section, "ranks")

		var passive_perk_data = PassivePerk.new()

		if !texture:
			texture = "res://sprites/missing.png"

		passive_perk_data.name = name
		passive_perk_data.texture = load(texture)
		passive_perk_data.ranks = _get_ranks(ranks)

		data.append(passive_perk_data)

	return data


static func _get_ranks(rank_data) -> Array[PassivePerk.Rank]:
	var ranks: Array[PassivePerk.Rank] = []
	var i: int = 0

	for element in rank_data:
		var rank = PassivePerk.Rank.new()

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
				_:
					print_debug("WARNING: unhandled rank key: %s" % key)

		# Remove the leading new line from rank description
		if rank.description.length() > 1:
			rank.description = rank.description.substr(1, rank.description.length())

		ranks.append(rank)

	return ranks


static func _resolve_multi_shot_number(rank: PassivePerk.Rank, variant):
	if !variant is int:
		print_debug("Multi shot number is not integer")

		return

	#rank.description += "\nIncreases the multi shot number of all towers by %s" % variant
	rank.description += "\n+%s multi shot" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_multi_shot(variant)
	)


static func _resolve_multi_shot_chance(rank: PassivePerk.Rank, variant):
	if !variant is float:
		print_debug("Multi shot chance is not float")

		return

	#rank.description += "\nIncreases the multi shot chance of all towers by %s%%" % (variant * 100)
	rank.description += "\n+%s%% multi shot chance" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_multi_shot_chance(variant)
	)


static func _resolve_attack_range(rank: PassivePerk.Rank, variant):
	if !variant is int:
		print_debug("Attack range is not integer")

		return

	rank.description += "\n+%s attack range" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_bonus_attack_range(variant)
	)


static func _resolve_attack_speed(rank: PassivePerk.Rank, variant):
	if !variant is float:
		print_debug("Attack speed is not integer")

		return

	rank.description += "\n+%s attack speed" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_bonus_attack_speed(variant)
	)


static func _resolve_burst_shot_number(rank: PassivePerk.Rank, variant):
	if !variant is int:
		print_debug("Burst shot number is not integer")

		return

	rank.description += "\n+%s burst shot" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_burst_shot(variant)
	)


static func _resolve_burst_shot_chance(rank: PassivePerk.Rank, variant):
	if !variant is float:
		print_debug("Burst shot chance is not float")

		return

	rank.description += "\n+%s%% burst shot chance" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_burst_shot_chance(variant)
	)


static func _resolve_projectile_speed(rank: PassivePerk.Rank, variant):
	if !variant is float:
		print_debug("projectile speed is not float")

		return

	rank.description += "\n+%s%% projectile speed" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_projectile_speed_mod(variant)
	)
