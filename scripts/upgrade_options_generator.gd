class_name UpgradeOptionsGenerator
extends RefCounted


func generate_upgrade_options(game: Game, amount: int) -> UpgradeOptions:
	var options: Array[UpgradeOption] = []

	options.append_array(_get_passive_options(game))
	
	if GameRules.CORE_AS_UPGRADE_OPTION:
		options.append(UpgradeFactory.add_core(game.player))

	if GameRules.WEAPON_UPGRADES:
		# Apply the weapon upgrades to this tower
		var main_tower = game.tower

		for weapon in game.game_data.tower_weapon_data:
			# Get rank up upgrade if tower already has the weapon
			if main_tower.weapon_dict.has(weapon.id):
				options.append(UpgradeFactory.rank_up_weapon(main_tower.weapon_dict[weapon.id]))
			else:
				options.append(UpgradeFactory.new_weapon(main_tower, weapon))

	if GameRules.TOWER_UPGRADES:
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
	options.append(UpgradeFactory.rank_up_specific_tower(game.tower))

	for tower_resource: TowerResource in game.game_data.tower_resource_dict.values():
		var tower_proto = game.game_data.tower_proto_dict[tower_resource.name]

		# Check if the building option already exists
		var existing_option: BuildingOption = game.building_options.get_building_option(
			tower_resource.name
		)

		if existing_option:
			options.append(UpgradeFactory.rank_up_tower(tower_proto, existing_option))

			continue

		if !tower_resource.can_be_offered_as_new_tower:
			continue

		options.append(UpgradeFactory.new_tower(
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
		var passive: PassiveUpgrade = game.game_data.passives_dict[passive_key]

		if game.player.upgrades.passives_dict.has(passive_key):
			if game.player.upgrades.can_rank_up_passive(passive_key):
				options.append(UpgradeFactory.rank_up_passive(passive_key, game.player))
		else:
			options.append(UpgradeFactory.new_passive(passive, game.player))

	return options
