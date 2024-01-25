class_name Entities
extends RefCounted

signal entity_added(params: SpawnEntityParams)
signal tower_registered(tower: Tower)

var towers: Array[Tower] = []

var _game: Game

var _cell_entity_dict = {}					# <Cell, Node>
var _tower_type_dict = {}					# <String, Array[Tower]>


func _init(game: Game):
	_game = game


func get_entities_at(cell: Cell) -> Array:
	if !_cell_entity_dict.has(cell):
		return []

	return _cell_entity_dict[cell]


func get_towers_of_type(tower_name: String) -> Array[Tower]:
	if !_tower_type_dict.has(tower_name):
		return []

	return _tower_type_dict[tower_name]


func spawn_tower(tower_resource: TowerResource, params: SpawnEntityParams, rank: int):
	params.entity_instantiated.connect(
		func(entity):
			_register_tower(tower_resource, entity, rank, params.cell)
	)

	entity_added.emit(params)


func _register_tower(tower_resource: TowerResource, tower: Tower, rank: int, cell: Cell):
	tower.set_resource(tower_resource)
	tower.set_cell_and_init(cell)
	tower.set_rank(rank)
	
	towers.append(tower)

	# TEMP: assuming all towers are solid
	PathUtilities.update_cell_is_solid(cell, true)

	if !_cell_entity_dict.has(cell):
		_cell_entity_dict[cell] = []

	_cell_entity_dict[cell].append(tower)

	tower.was_killed.connect(
		func():
			_cell_entity_dict[cell].erase(tower)
			PathUtilities.update_cell_is_solid(cell, false)
			towers.erase(tower)
			_tower_type_dict.erase(tower)
	)

	if !_tower_type_dict.has(tower.tower_name):
		var tower_array: Array[Tower] = [tower]
		_tower_type_dict[tower.tower_name] = tower_array
	else:
		_tower_type_dict[tower.tower_name].append(tower)
		
	tower_registered.emit(tower)


func get_is_cell_occupied(cell: Cell) -> bool:
	return _cell_entity_dict.has(cell)
