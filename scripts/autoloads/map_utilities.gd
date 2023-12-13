extends Node

signal mouse_entered_cell(cell: Cell)
signal mouse_clicked_cell(cell: Cell)
signal mouse_hovered_outside_map()
signal mouse_hovered_inside_map()

var _map: Map


func set_map(map: Map):
	_map = map


func get_random_cell() -> Cell:
	return _map.cells.pick_random()


func get_cell_at_scene_position(vector: Vector2) -> Cell:
	var x = floori((vector.x + 8) * GameConstants.UNITS_PER_PIXEL)
	var y = floori((vector.y + 8) * GameConstants.UNITS_PER_PIXEL)

	return _map.get_cell_at(x, y)


func get_cell_at_map_position(vector: Vector2) -> Cell:
	var x = floori(vector.x)
	var y = floori(vector.y)

	return _map.get_cell_at(x, y)
