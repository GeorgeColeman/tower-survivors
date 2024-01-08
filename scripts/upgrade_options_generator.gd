# TODO: make this class pure. Is only upgrade generator.
class_name UpgradeOptionsGenerator
extends RefCounted


func generate_upgrade_options(game: Game, amount: int) -> UpgradeOptions:
	var options: Array[UpgradeOption] = []

	options.append_array(_get_passive_options(game))
	#options.append_array(_get_old_upgrades(game))

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

	for tower in game.game_data.towers:
		var unpacked_tower = tower.instantiate() as Tower

		# Initialise weapons so we can get weapon info for the description
		unpacked_tower.init_weapons()

		# Check if the building option already exists
		var existing_option: BuildingOption = game.building_options.get_building_option(tower)

		if existing_option:
			options.append(PerkFactory.rank_up_tower(unpacked_tower, existing_option))

			continue

		if !unpacked_tower.is_possible_new_tower_upgrade_perk:
			continue

		options.append(PerkFactory.new_tower(
			unpacked_tower,
			func():
				game.building_options.add_building_option(tower, game.player)
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


func _get_old_upgrades(game: Game) -> Array[UpgradeOption]:
	var options: Array[UpgradeOption] = []

	for upgrade in game.game_data.upgrade_resources:
		options.append(PerkFactory.passive_upgrade(
			upgrade,
			func():
				var perk = Perk.new()
				perk.upgrade_resource = upgrade
				game.player.upgrades.add_perk(perk)
		))

	return options
