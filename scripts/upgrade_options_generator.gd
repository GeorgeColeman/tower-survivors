class_name UpgradeOptionsGenerator
extends RefCounted


func generate_upgrade_options(game: Game, amount: int) -> UpgradeOptions:
	var options: Array[UpgradeOption] = []

	options.append_array(_get_passive_options(game))

	if GameRules.WEAPON_PERKS:
		# Apply the weapon perks to this tower
		var main_tower = game.tower

		for weapon in game.game_data.tower_weapon_data:
			# Get rank up perk if tower already has the weapon
			if main_tower.weapon_dict.has(weapon.id):
				options.append(PerkFactory.rank_up_weapon(main_tower.weapon_dict[weapon.id]))
			else:
				options.append(PerkFactory.new_weapon(main_tower, weapon))


	if GameRules.TOWER_PERKS:
		options.append_array(_get_tower_options(game))

	return UpgradeOptions.new(
		Utilities.get_random_unique_elements(
			options,
			amount
		)
	)


func _get_tower_options(game: Game) -> Array[UpgradeOption]:
	var options: Array[UpgradeOption] = []

	# Add main tower rank up option
	options.append(PerkFactory.rank_up_specific_tower(game.tower))

	for tower_resource: TowerResource in game.game_data.tower_resource_dict.values():
		var tower_proto = game.game_data.tower_proto_dict[tower_resource.name]

		# Check if the building option already exists
		var existing_option: BuildingOption = game.building_options.get_building_option(
			tower_resource.name
		)

		if existing_option:
			options.append(PerkFactory.rank_up_tower(tower_proto, existing_option))

			continue

		if !tower_proto.is_possible_new_tower_upgrade_perk:
			continue

		options.append(PerkFactory.new_tower(
			tower_proto,
			func():
				game.building_options.add_building_option(
					tower_resource,
					tower_proto,
					tower_resource.tower_scene,
					game.player
				)
		))

	return options


func _get_passive_options(game: Game) -> Array[UpgradeOption]:
	var options: Array[UpgradeOption] = []

	for passive_key in game.game_data.passives_dict.keys():
		var passive: PassivePerk = game.game_data.passives_dict[passive_key]

		if game.player.upgrades.passives_dict.has(passive_key):
			if game.player.upgrades.can_rank_up_passive(passive_key):
				options.append(PerkFactory.rank_up_passive(passive_key, game.player))
		else:
			options.append(PerkFactory.new_passive(passive, game.player))

	return options
