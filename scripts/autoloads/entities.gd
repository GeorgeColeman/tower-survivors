class_name Entities
extends Node

signal entity_added(params: SpawnEntityParams)

var towers: Array[Tower] = []

var _game: Game

# <Cell, Node>
var _cell_entity_dict = {}


func _init(game: Game):
	_game = game


func get_entities_at(cell: Cell) -> Array:
	if !_cell_entity_dict.has(cell):
		return []

	return _cell_entity_dict[cell]


func apply_passive_rank_to_existing_towers(passive: PassiveUpgrade):
	for tower in towers:
		passive.apply_current_rank_to_tower(tower)


func spawn_tower(tower_resource: TowerResource, params: SpawnEntityParams):
	entity_added.emit(params)

	_register_tower(tower_resource, params.spawned_entity, params.cell)


func _register_tower(tower_resource: TowerResource, tower: Tower, cell: Cell):
	tower.set_resource(tower_resource)
	tower.set_cell_and_init(cell)

	towers.append(tower)

	# TEMP: assuming all towers are solid
	PathUtilities.update_cell_is_solid(cell, true)

	if !_cell_entity_dict.has(cell):
		_cell_entity_dict[cell] = []

	_cell_entity_dict[cell].append(tower)

	for passive in _game.player.upgrades.passives_dict.values():
		passive.apply_all_ranks_to_tower(tower)

	tower.was_killed.connect(
		func():
			_cell_entity_dict[cell].erase(tower)
			PathUtilities.update_cell_is_solid(cell, false)
			towers.erase(tower)
	)


func get_is_cell_occupied(cell: Cell) -> bool:
	return _cell_entity_dict.has(cell)
