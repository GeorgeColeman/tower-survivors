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
