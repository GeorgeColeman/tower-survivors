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
		_on_passive_rank_added
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


func add_or_rank_up_passive_upgrade(name: String) -> String:
	if not game_data.passives_dict.has(name):
		return "No passive upgrade '%s'" % name

	var passive_upgrade: PassiveUpgrade = game_data.passives_dict[name]

	if player.upgrades.passives_dict.has(name):
		if player.upgrades.can_rank_up_passive(name):
			player.upgrades.rank_up_passive(name)

			return "Ranked up passive upgrade"
		else:
			return "Unable to rank up passive upgrade (probably max rank)"
	else:
		player.upgrades.add_passive(passive_upgrade.clone())

		return "Added new passive upgrade '%s'" % name


func _on_passive_rank_added(passive: PassiveUpgrade):
	for tower in _entities.towers:
		var attached_passive: PassiveUpgradeTowerAttached = tower.get_passive_upgrade(passive.name)

		# HACK: get if the passive is new and add to tower
		if !attached_passive:
			attached_passive = passive.get_passive_upgrade_tower_attached()
			tower.add_passive_upgrade(attached_passive)

		if GameRules.PASSIVE_LIMITED_TO_TOWER_RANK:
			attached_passive.match_tower_rank_and_apply(tower)
		else:
			attached_passive.ignore_tower_rank_and_apply_max(tower)


func _on_tower_registered(tower: Tower):
	_apply_passive_upgrades_to_tower(tower)


func _apply_passive_upgrades_to_tower(tower: Tower):
	for passive in player.upgrades.passives_dict.values():
		var attached_passive: PassiveUpgradeTowerAttached = passive.get_passive_upgrade_tower_attached()

		# Add the passive upgrade to the tower
		tower.add_passive_upgrade(attached_passive)

		if GameRules.PASSIVE_LIMITED_TO_TOWER_RANK:
			attached_passive.match_tower_rank_and_apply(tower)
		else:
			attached_passive.ignore_tower_rank_and_apply_max(tower)


func _on_building_option_upgraded(option: BuildingOption):
	if !GameRules.UPGRADE_EXISTING:
		return

	_rank_up_existing_towers_to_building_option_rank(option)


func _rank_up_existing_towers_to_building_option_rank(option: BuildingOption):
	for tower in _entities.get_towers_of_type(option.tower_resource.name):
		tower.rank.set_min_rank(option._rank)
