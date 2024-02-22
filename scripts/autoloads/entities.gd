class_name Entities
extends RefCounted

signal entity_added(params: SpawnEntityParams)
signal tower_registered(tower: Tower)

var towers: Array[Tower] = []

var _cell_entity_dict = {}					# <Cell, Node>
var _tower_type_dict = {}					# <String, Array[Tower]>


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
			params.entity_destroyed = entity.was_killed
	)

	entity_added.emit(params)


func _register_tower(tower_resource: TowerResource, tower: Tower, rank: int, cell: Cell):
	tower.set_resource(tower_resource)

	towers.append(tower)

	# Handle base cells
	var base_cells = MapUtilities.get_base_cells(cell, tower_resource.base_area)
	#print_debug("TODO: handle base cells. Number of base cells: %s" % base_cells.size())

	tower.set_cell_and_init(cell, base_cells)
	tower.rank.set_rank(rank)

	for base_cell in base_cells:
		# TEMP: assuming all towers are solid
		PathUtilities.update_cell_is_solid(base_cell, true)

		if !_cell_entity_dict.has(base_cell):
			_cell_entity_dict[base_cell] = []

		_cell_entity_dict[base_cell].append(tower)

	tower.was_killed.connect(_unregister_tower)

	if !_tower_type_dict.has(tower.tower_name):
		var tower_array: Array[Tower] = [tower]
		_tower_type_dict[tower.tower_name] = tower_array
	else:
		_tower_type_dict[tower.tower_name].append(tower)

	tower_registered.emit(tower)


func _unregister_tower(tower: Tower):
	for cell in tower.base_cells:
		_cell_entity_dict[cell].erase(tower)
		PathUtilities.update_cell_is_solid(cell, false)

	towers.erase(tower)
	_tower_type_dict.erase(tower)


func get_is_cell_occupied(cell: Cell) -> bool:
	return _cell_entity_dict.has(cell)
