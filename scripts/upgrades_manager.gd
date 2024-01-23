# ---------
# Mediator.
# ---------

class_name UpgradesManager
extends RefCounted

var game_data: GameData
var player: Player

var _building_options: BuildingOptions
var _upgrades: Upgrades							# Actually 'PassiveUpgrades'
var _entities: Entities							# Need this to upgrade existing entities

var _upgrade_options_generator: UpgradeOptionsGenerator


func _init(building_options: BuildingOptions, upgrades: Upgrades, entities: Entities):
	_building_options = building_options
	_upgrades = upgrades
	_entities = entities

	_upgrade_options_generator = UpgradeOptionsGenerator.new()

	building_options.option_upgraded.connect(_on_building_option_upgraded)

	_entities.tower_registered.connect(_on_tower_registered)


func set_player(p_player: Player):
	player = p_player

	player.levelled_up.connect(
		func():
			generate_new_upgrade_options()
	)

	player.upgrades.passive_rank_added.connect(
		_apply_passive_rank_to_existing_towers
	)

	player.gold_changed.connect(
		func(_gold: int):
			_building_options.update_build_options_can_build(player)
	)

	player.cores_changed.connect(
		func(_cores: int):
			_building_options.update_build_options_can_build(player)
	)


func generate_new_upgrade_options():
	_upgrades.set_upgrade_options(
		_upgrade_options_generator.generate_upgrade_options(
			game_data,
			_building_options,
			player,
			3
			)
	)


func _apply_passive_rank_to_existing_towers(passive: PassiveUpgrade):
	for tower in _entities.towers:
		# HACK: get if the passive is new and add to tower
		if passive.is_rank_one:
			tower.passive_upgrades.append(passive)

		passive.apply_current_rank_to_tower(tower)


func _on_tower_registered(tower: Tower):
	for passive in player.upgrades.passives_dict.values():
		# Add the passive upgrade to the tower
		tower.passive_upgrades.append(passive)

		passive.apply_all_ranks_to_tower(tower)


func _on_building_option_upgraded(option: BuildingOption):
	if !GameRules.UPGRADE_EXISTING:
		return

	for tower in _entities.get_towers_of_type(option.tower_resource.name):
		tower.add_rank(1)
