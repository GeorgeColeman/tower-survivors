extends Node

signal spawn_entity_requested(params: SpawnEntityParams)

# <Cell, Node>
var _cell_entity_dict = {}


func set_cell_entity_dict(dict):
	_cell_entity_dict = dict


func spawn_entity(params: SpawnEntityParams):
	spawn_entity_requested.emit(params)


func get_is_cell_occupied(cell: Cell) -> bool:
	return _cell_entity_dict.has(cell)
