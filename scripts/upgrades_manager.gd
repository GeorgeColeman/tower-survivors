class_name UpgradesManager
extends RefCounted

signal passive_upgrade_added(upgrade: UpgradeResource)

var upgrades: Array[UpgradeResource] = []

var _game_data: GameData
var _building_options: BuildingOptions


func _init(game_data: GameData, building_options: BuildingOptions):
	_game_data = game_data
	_building_options = building_options


func generate_upgrade_options(game: Game, amount: int) -> UpgradeOptions:
	var options: Array[UpgradeOption] = []

	for upgrade in _game_data.upgrade_resources:
		options.append(_passive_upgrade_option(upgrade))

	if GameRules.WEAPON_PERKS:
		# Apply the weapon perks to this tower
		var main_tower = game.tower

		for weapon in _game_data.tower_weapon_data:
			# Get rank up perk if tower already has the weapon
			if main_tower.weapon_dict.has(weapon.id):
				options.append(_rank_up_weapon_option(main_tower.weapon_dict[weapon.id]))
			else:
				options.append(_new_weapon_option(main_tower, weapon))


	if GameRules.TOWER_PERKS:
		for tower in _game_data.towers:
			var unpacked_tower = tower.instantiate() as Tower

			# Initialise weapons so we can get weapon info for the description
			unpacked_tower.init_weapons()

			# Check if the building option already exists
			var existing_option: BuildingOption = _building_options.get_building_option(tower)

			if existing_option:
				options.append(_tower_rank_up_option(unpacked_tower, existing_option))

				continue

			if !unpacked_tower.is_possible_new_tower_upgrade_perk:
				continue

			options.append(_new_tower_upgrade_option(unpacked_tower, tower))

	return UpgradeOptions.new(
		Utilities.get_random_unique_elements(
			options,
			amount
		)
	)


func _passive_upgrade_option(upgrade: UpgradeResource) -> UpgradeOption:
	var option = UpgradeOption.new(
		upgrade.name,
		"Passive Upgrade",
		upgrade.get_description(),
		func():
			_add_passive_upgrade(upgrade)
	)

	option.texture = upgrade.main_texture

	return option


func _new_weapon_option(tower: Tower, weapon_data: TowerWeaponData) -> UpgradeOption:
	var option = UpgradeOption.new(
		weapon_data.name,
		"CATEGORY UNUSED",
		"TODO: weapon data description",
		func():
			tower.attach_weapon_from_weapon_data(weapon_data)
	)

	return option


func _rank_up_weapon_option(weapon: TowerWeapon) -> UpgradeOption:
	var option = UpgradeOption.new(
		weapon.weapon_name,
		"CATEGORY UNUSED",
		"TODO: weapon rank up description",
		func():
			print_debug("TODO: upgrade existing weapon")
	)

	return option


func _tower_rank_up_option(tower: Tower, existing: BuildingOption) -> UpgradeOption:
	var option = UpgradeOption.new(
		tower.tower_name,
		"Rank Up Tower",
		str("Rank: ", existing.rank, " > Rank: ", existing.rank + 1),
		func(): existing.upgrade()
	)

	option.texture = tower.main_sprite_2d.texture

	return option


func _new_tower_upgrade_option(tower: Tower, tower_packed: PackedScene) -> UpgradeOption:
	var option = UpgradeOption.new(
			tower.tower_name,
			"New Tower",
			tower.weapons_description,
			func():
				_building_options.add_building_option_packed(tower_packed)
	)

	option.texture = tower.main_sprite_2d.texture

	return option


func _add_passive_upgrade(upgrade_resource: UpgradeResource):
	upgrades.append(upgrade_resource)

	passive_upgrade_added.emit(upgrade_resource)
