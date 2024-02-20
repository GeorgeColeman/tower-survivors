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
	var x = floori((vector.x + GameConstants.PIXEL_SCALE * 0.5) * GameConstants.UNITS_PER_PIXEL)
	var y = floori((vector.y + GameConstants.PIXEL_SCALE * 0.5) * GameConstants.UNITS_PER_PIXEL)

	return _map.get_cell_at(x, y)


func get_cell_at_map_position(vector: Vector2) -> Cell:
	var x = floori(vector.x)
	var y = floori(vector.y)

	return _map.get_cell_at(x, y)


func get_cell_neighbours(cell: Cell) -> Array[Cell]:
	return _map.get_cell_neighbours(cell)


func get_base_cells(origin_cell: Cell, base_size: Vector2i) -> Array[Cell]:
	var base_cells: Array[Cell] = []

	for y in base_size.y:
		for x in base_size.x:
			var cell = _map.get_cell_at(origin_cell.x + x, origin_cell.y + y)

			if !cell:
				print_debug("WARNING: base cell is null")

				continue

			base_cells.append(cell)

	return base_cells
