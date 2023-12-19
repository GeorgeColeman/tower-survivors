extends Node

signal entity_added(params: SpawnEntityParams)

var towers: Array[Tower] = []

var _upgrades_manager: UpgradesManager

# <Cell, Node>
var _cell_entity_dict = {}


func set_game(game: Game):
	_upgrades_manager = game.upgrades_manager

	_upgrades_manager.passive_upgrade_added.connect(
		func(upgrade: UpgradeResource):
			# Upgrade existing towers
			for tower in towers:
				upgrade.add_to_tower(tower)
	)


func set_cell_entity_dict(dict):
	_cell_entity_dict = dict


func spawn_entity(params: SpawnEntityParams):
	entity_added.emit(params)

	if params.spawned_entity is Tower:
		_register_tower(params.spawned_entity)


func _register_tower(tower: Tower):
	towers.append(tower)

	# Add existing passive perks to new tower
	for perk in _upgrades_manager.upgrades:
		perk.add_to_tower(tower)

	tower.was_killed.connect(func(): towers.erase(tower))


func get_is_cell_occupied(cell: Cell) -> bool:
	return _cell_entity_dict.has(cell)
