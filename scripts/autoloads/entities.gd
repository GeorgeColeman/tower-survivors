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


func apply_passive_rank_to_existing_towers(passive: PassivePerk):
	for tower in towers:
		passive.apply_current_rank_to_tower(tower)


func spawn_entity(params: SpawnEntityParams):
	entity_added.emit(params)

	if params.spawned_entity is Tower:
		_register_tower(params.spawned_entity)


func _register_tower(tower: Tower):
	towers.append(tower)

	var cell = tower.cell

	# TEMP: assuming all towers are solid
	PathUtilities.updated_cell_is_solid.emit(cell, true)

	if !_cell_entity_dict.has(cell):
		_cell_entity_dict[cell] = []

	_cell_entity_dict[cell].append(tower)

	for passive in _game.player.upgrades.passives_dict.values():
		passive.apply_all_ranks_to_tower(tower)

	tower.was_killed.connect(
		func():
			_cell_entity_dict[cell].erase(tower)
			PathUtilities.updated_cell_is_solid.emit(cell, false)
			towers.erase(tower)
	)


func get_is_cell_occupied(cell: Cell) -> bool:
	return _cell_entity_dict.has(cell)
