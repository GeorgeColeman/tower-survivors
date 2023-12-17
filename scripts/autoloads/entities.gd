extends Node

signal spawn_entity_requested(params: SpawnEntityParams)

var _entity_drawer: EntityDrawer
# <Cell, Node>
var _cell_entity_dict = {}


func set_entity_drawer(entity_drawer: EntityDrawer):
	_entity_drawer = entity_drawer


func set_cell_entity_dict(dict):
	_cell_entity_dict = dict


func spawn_entity(params: SpawnEntityParams):
	spawn_entity_requested.emit(params)


func get_is_cell_occupied(cell: Cell) -> bool:
	return _cell_entity_dict.has(cell)
