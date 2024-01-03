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

		ranks.append(rank)

	return ranks


static func _resolve_multi_shot_number(rank: PassivePerk.Rank, variant):
	if !variant is int:
		print_debug("Multi shot number is not integer")

		return

	rank.description += "\nIncreases the multi shot number of all towers by %s" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_multi_shot(variant)
	)


static func _resolve_multi_shot_chance(rank: PassivePerk.Rank, variant):
	if !variant is float:
		print_debug("Multi shot chance is not float")

		return

	rank.description += "\nIncreases the multi shot chance of all towers by %s%%" % (variant * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_multi_shot_chance(variant)
	)
