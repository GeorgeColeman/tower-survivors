class_name Towers
extends Node2D

signal entity_added(params: SpawnEntityParams)
signal tower_registered(tower: Tower)

var towers: Array[Tower] = []

var _cell_tower_dict = {}					# <Cell, Tower>
var _tower_type_dict = {}					# <String, Array[Tower]>


func get_towers_at(cell: Cell) -> Array:
	if !_cell_tower_dict.has(cell):
		return []

	return _cell_tower_dict[cell]


func get_towers_of_type(tower_name: String) -> Array[Tower]:
	if !_tower_type_dict.has(tower_name):
		return []

	return _tower_type_dict[tower_name]


func spawn_tower(
	tower_resource: TowerResource,
	params: SpawnEntityParams,
	rank: int
) -> Tower:
	var tower: Tower = params.entity_scene.instantiate()

	add_child(tower)
	var position = GameUtilities.get_scene_position(params.cell, params.base_area)
	tower.position = position

	_register_tower(tower_resource, tower, rank, params.cell)

	return tower


func _register_tower(
	tower_resource: TowerResource,
	tower: Tower,
	rank: int,
	cell: Cell
):
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

		if !_cell_tower_dict.has(base_cell):
			_cell_tower_dict[base_cell] = []

		_cell_tower_dict[base_cell].append(tower)

	tower.was_killed.connect(_unregister_tower)

	if !_tower_type_dict.has(tower.tower_name):
		var tower_array: Array[Tower] = [tower]
		_tower_type_dict[tower.tower_name] = tower_array
	else:
		_tower_type_dict[tower.tower_name].append(tower)

	tower_registered.emit(tower)


func _unregister_tower(tower: Tower):
	for cell in tower.base_cells:
		_cell_tower_dict[cell].erase(tower)
		PathUtilities.update_cell_is_solid(cell, false)

	towers.erase(tower)
	_tower_type_dict.erase(tower)


func get_is_cell_occupied(cell: Cell) -> bool:
	return _cell_tower_dict.has(cell)
