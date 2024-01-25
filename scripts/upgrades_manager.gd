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


func _on_passive_rank_added(passive: PassiveUpgrade):
	for tower in _entities.towers:
		var attached_passive: PassiveUpgradeTowerAttached = tower.get_passive_upgrade(passive.name)

		if !attached_passive:
			attached_passive = passive.get_passive_upgrade_tower_attached()
			tower.add_passive_upgrade(attached_passive)
		#else:
			#existing_passive.rank_up()

		## HACK: get if the passive is new and add to tower
		#if passive.is_rank_one:
			#tower.add_passive_upgrade(cloned_passive)

		if GameRules.PASSIVE_LIMITED_TO_TOWER_RANK:
			attached_passive.match_tower_rank_and_apply(tower)
		else:
			attached_passive.ignore_tower_rank_and_apply_max(tower)
			#passive.apply_current_rank_to_tower(tower)


func _on_tower_registered(tower: Tower):
	for passive in player.upgrades.passives_dict.values():
		var attached_passive: PassiveUpgradeTowerAttached = passive.get_passive_upgrade_tower_attached()

		# Add the passive upgrade to the tower
		tower.add_passive_upgrade(attached_passive)

		if GameRules.PASSIVE_LIMITED_TO_TOWER_RANK:
			attached_passive.match_tower_rank_and_apply(tower)
		else:
			attached_passive.ignore_tower_rank_and_apply_max(tower)
			#passive.apply_all_ranks_to_tower(tower)


func _on_building_option_upgraded(option: BuildingOption):
	if !GameRules.UPGRADE_EXISTING:
		return

	for tower in _entities.get_towers_of_type(option.tower_resource.name):
		tower.add_rank(1)
