class_name UpgradeOptionsGenerator
extends RefCounted


func generate_upgrade_options(
	game_data: GameData,
	building_options: BuildingOptions,
	player: Player,
	amount: int
) -> UpgradeOptions:
	var options: Array[UpgradeOption] = []

	options.append_array(_get_passive_options(game_data, player))
	options.append_array(_get_item_options(game_data, player))

	if GameRules.CORE_AS_UPGRADE_OPTION:
		options.append(UpgradeOptionFactory.add_core(player))

	if GameRules.TOWER_UPGRADES:
		options.append_array(_get_tower_options(game_data, building_options, player))

	return UpgradeOptions.new(
		Utilities.get_random_unique_elements(
			options,
			amount
		)
	)


func _get_tower_options(
	game_data: GameData,
	building_options: BuildingOptions,
	player: Player
) -> Array[UpgradeOption]:
	var options: Array[UpgradeOption] = []

	for tower_resource: TowerResource in game_data.tower_resource_dict.values():
		# Check if the building option already exists
		var existing_option: BuildingOption = building_options.get_building_option(
			tower_resource.name
		)

		if existing_option:
			options.append(UpgradeOptionFactory.rank_up_tower(existing_option))

			continue

		if tower_resource.is_main_tower:
			continue

		options.append(UpgradeOptionFactory.new_tower(
			tower_resource,
			func():
				building_options.add_building_option(tower_resource, player)
		))

	return options


func _get_passive_options(game_data: GameData, player: Player) -> Array[UpgradeOption]:
	var options: Array[UpgradeOption] = []

	for passive_key in game_data.passives_dict.keys():
		var passive: PassiveUpgrade = game_data.passives_dict[passive_key]

		if player.upgrades.passives_dict.has(passive_key):
			if player.upgrades.can_rank_up_passive(passive_key):
				options.append(UpgradeOptionFactory.rank_up_passive(passive_key, player))
		else:
			options.append(UpgradeOptionFactory.new_passive(passive, player))

	return options


func _get_item_options(game_data: GameData, player: Player):
	var options: Array[UpgradeOption] = []

	for item in game_data.items:
		options.append(UpgradeOptionFactory.TEST_get_item_option(item))

	return options
