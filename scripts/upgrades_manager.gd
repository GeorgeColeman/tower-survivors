class_name UpgradesManager
extends Node

signal passive_upgrade_added(upgrade: UpgradeResource)

var upgrades: Array[UpgradeResource] = []

var _game_data: GameData
var _building_options: BuildingOptions


func _init(game_data: GameData, building_options: BuildingOptions):
	_game_data = game_data
	_building_options = building_options


func generate_upgrade_options(amount: int) -> UpgradeOptions:
	var options: Array[UpgradeOption] = []

	for upgrade in _game_data.upgrade_resources:
		options.append(
			UpgradeOption.new(
				upgrade.name,
				"Passive Upgrade",
				"Adds a passive upgrade to all towers",
				func():
					_add_passive_upgrade(upgrade)
		)
		)

	for tower in _game_data.towers:
		var unpacked_tower = tower.instantiate() as Tower

		# Check if the building option already exists
		var existing_option = _building_options.get_building_option(tower)

		if existing_option:
			options.append(
				UpgradeOption.new(
					unpacked_tower.name,
					"Rank Up Tower",
					"Increases the power of an existing tower.",
					func(): existing_option.upgrade()
				)
			)

			continue

		options.append(
			UpgradeOption.new(
				unpacked_tower.name,
				"New Tower",
				"Adds a new tower to build.",
				func():
					_building_options.add_building_option_packed(tower)
		)
		)

	return UpgradeOptions.new(
		Utilities.get_random_unique_elements(
			options,
			amount
		)
	)


func _add_passive_upgrade(upgrade_resource: UpgradeResource):
	upgrades.append(upgrade_resource)

	passive_upgrade_added.emit(upgrade_resource)
