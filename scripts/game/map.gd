class_name Map
extends RefCounted

var width: int
var height: int
var cells: Array[Cell]
var border_cells: Array[Cell]

var center_cell: Cell
var center: Vector2

var mountains: Array[bool] = []
var water: Array[bool] = []

var _big_mountains: Array[bool] = []
var _big_mountain_bases: Array[bool] = []

var _center_x: int
var _center_y: int

#var _noise: Array[float]
var _mountain_height: float = 0.70
var _water_max_height: float = 0.30


func _init(p_width: int, p_height: int, p_cells: Array[Cell], noise: Array[float]):
	width = p_width
	height = p_height
	cells = p_cells
	_center_x = floori(width * .5)
	_center_y = floori(height * .5)
	center = Vector2(_center_x, _center_y)
	center_cell = get_cell_at(_center_x, _center_y)

	border_cells = []

	mountains.resize(width * height)
	water.resize(width * height)

	for y in height:
		for x in width:
			var index = x + y * width

			if y == 0 || x == 0 || y == height - 1 || x == width - 1:
				border_cells.append(cells[index])

			mountains[index] = (noise[index] >= _mountain_height)

			if mountains[index]:
				PathUtilities.update_cell_is_solid(p_cells[index], true)

			water[index] = (noise[index] <= _water_max_height)

			if water[index]:
				PathUtilities.update_cell_is_solid(p_cells[index], true)

	_get_big_mountains()


func _get_big_mountains():
	_big_mountains.resize(width * height)
	_big_mountain_bases.resize(width * height)

	for y in height:
		for x in width:
			var index = x + y * width

			_big_mountains[index] = false
			_big_mountain_bases[index] = false

	var number_of_big_mountains: int

	for y in height:
		for x in width:
			var index = x + y * width

			if !mountains[index]:
				continue

			if _big_mountain_bases[index]:
				continue

			var north = get_cell_at(x, y + 1)
			var north_east = get_cell_at(x + 1, y + 1)
			var east = get_cell_at(x + 1, y)

			if !north || !north_east || !east:
				continue

			if !mountains[north.i] || !mountains[north_east.i] || !mountains[east.i]:
				continue

			if _get_is_big_mountain_at(north.i) || _get_is_big_mountain_at(north_east.i) || _get_is_big_mountain_at(east.i):
				continue

			if randf() < 0.5:
				continue

			_big_mountains[index] = true
			_big_mountain_bases[north.i] = true
			_big_mountain_bases[north_east.i] = true
			_big_mountain_bases[east.i] = true


func _get_is_big_mountain_at(index: int) -> bool:
	if _big_mountains[index] || _big_mountain_bases[index]:
		return true

	return false


func index_to_coordinates(index: int):
	var x = index % width
	var y = floor(float(index) / width)
	return Vector2(x, y)


func get_cell_at(x: int, y: int) -> Cell:
	if y < 0 || x < 0 || y >= height || x >= width:
		return null

	return cells[x + y * width]


func get_cell_at_world(x: int, y: int) -> Cell:
	var pixel_scale = GameConstants.PIXEL_SCALE
	if x % pixel_scale != 0 || y % pixel_scale != 0:
		print_debug("X or y are not divisible by the pixel scale: ", pixel_scale)

	var local_x = x as float / pixel_scale
	var local_y = y as float / pixel_scale

	return get_cell_at(local_x, local_y)


func get_cells_in_circle(origin_cell: Cell, radius: float) -> Array[Cell]:
	var cells_in_circle: Array[Cell] = []

	for cell in cells:
		if Utilities.distance_between(origin_cell.position, cell.position) > radius:
			continue

		cells_in_circle.append(cell)

	return cells_in_circle


func get_cells_in_radius_from_base(radius: float, base: Array[Cell]) -> Array[Cell]:
	var cells_in_radius: Array[Cell] = []
	var cells_to_check: Array[Cell] = base.duplicate()			# Make sure you use this
	var checked_cells: Array[Cell] = []

	while cells_to_check.size() > 0:
		var cell_to_check = cells_to_check.pop_back()
		var cell_in_radius: bool = false

		checked_cells.append(cell_to_check)

		for base_cell in base:
			if Utilities.distance_between(base_cell.position, cell_to_check.position) <= radius:
				cell_in_radius = true

				break

		if !cell_in_radius:
			continue

		cells_in_radius.append(cell_to_check)

		for n_cell in get_cell_neighbours(cell_to_check):
			if checked_cells.has(n_cell):
				continue

			if cells_to_check.has(n_cell):
				continue

			cells_to_check.append(n_cell)

	return cells_in_radius


func get_cell_neighbours(centre_cell: Cell) -> Array[Cell]:
	var neighbours: Array[Cell] = []

	var north_neighbour = get_cell_at(centre_cell.x, centre_cell.y + 1)
	var east_neighbour = get_cell_at(centre_cell.x + 1, centre_cell.y)
	var south_neighbour = get_cell_at(centre_cell.x, centre_cell.y - 1)
	var west_neighbour = get_cell_at(centre_cell.x - 1, centre_cell.y)

	if north_neighbour: neighbours.append(north_neighbour)
	if east_neighbour: neighbours.append(east_neighbour)
	if south_neighbour: neighbours.append(south_neighbour)
	if west_neighbour: neighbours.append(west_neighbour)

	return neighbours


func get_map_feature_at(cell: Cell) -> MapFeature:
	if _big_mountains[cell.i]:
		return MapFeature.BIG_MOUNTAIN

	if _big_mountain_bases[cell.i]:
		return MapFeature.MOUNTAIN_BASE

	if mountains[cell.i]:
		return MapFeature.SMALL_MOUNTAIN

	return MapFeature.NONE


enum MapFeature {
	NONE,
	SMALL_MOUNTAIN,
	MOUNTAIN_BASE,
	BIG_MOUNTAIN
}
