class_name Map
extends RefCounted

var width: int
var height: int
var cells: Array[Cell]
var border_cells: Array[Cell]

var center_cell: Cell
var center: Vector2

var _center_x: int
var _center_y: int


func _init(_width: int, _height: int, _cells: Array[Cell]):
	width = _width
	height = _height
	cells = _cells
	_center_x = floori(width * .5)
	_center_y = floori(height * .5)
	center = Vector2(_center_x, _center_y)
	center_cell = get_cell_at(_center_x, _center_y)

	border_cells = []

	for y in height:
		for x in width:
			if y == 0 || x == 0 || y == height - 1 || x == width - 1:
				border_cells.append(cells[x + y * width])


func index_to_coordinates(index: int):
	var x = index % width
	var y = floor(float(index) / width)
	return Vector2(x, y)


func get_cell_at(x: int, y: int) -> Cell:
	if y < 0 || x < 0 || y >= height || x >= width:
		return null

	return cells[x + y * width]


func get_cell_at_world(x: int, y: int) -> Cell:
	if x % 16 != 0 || y % 16 != 0:
		print_debug("X or y are not divisible by 16")

	var local_x = x / 16
	var local_y = y / 16

	return get_cell_at(local_x, local_y)


func get_cells_in_circle(centre_cell: Cell, radius: float) -> Array[Cell]:
	var cells_in_circle: Array[Cell] = []

	for cell in cells:
		if distance_between(centre_cell, cell) > radius:
			continue

		cells_in_circle.append(cell)

	return cells_in_circle


func get_cell_neighbours(centre_cell: Cell) -> Array[Cell]:
	var neighbours:Array[Cell]

	var north_neighbour = get_cell_at(centre_cell.x, centre_cell.y + width)
	var east_neighbour = get_cell_at(centre_cell.x + 1, centre_cell.y)
	var south_neighbour = get_cell_at(centre_cell.x, centre_cell.y - width)
	var west_neighbour = get_cell_at(centre_cell.x - 1, centre_cell.y)

	if north_neighbour: neighbours.append(north_neighbour)
	if east_neighbour: neighbours.append(east_neighbour)
	if south_neighbour: neighbours.append(south_neighbour)
	if west_neighbour: neighbours.append(west_neighbour)

	return neighbours


func distance_between(cell_a: Cell, cell_b: Cell) -> float:
	return sqrt((cell_b.x - cell_a.x) ** 2 + (cell_b.y - cell_a.y) ** 2)
