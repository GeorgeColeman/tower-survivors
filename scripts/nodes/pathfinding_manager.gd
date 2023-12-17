class_name PathfindingManager
extends Node2D

signal pathfinding_grid_was_modified()

@export var create_obstacles_on_click: bool

@onready var mob_path_lines_container = $MobPathLinesContainer

var astar_grid = AStarGrid2D.new()
var grid_size: Vector2i
var cell_size: Vector2i
var offset = -Vector2.ONE * .5 * 16
var cell_path_dict = {}

# <Cell, bool>
var _node_update_dict = {}
var _update_nodes = false


var draw_pathfinding_grid = false:
	set(value):
		draw_pathfinding_grid = value
		queue_redraw()

var draw_mob_paths = false:
	set(value):
		draw_mob_paths = value
		mob_path_lines_container.visible = value


func _ready():
	PathUtilities.set_pathfinding_manager(self)
	PathUtilities.updated_cell_is_solid.connect(
		func(cell: Cell, is_solid: bool):
			_update_nodes = true
			_node_update_dict[cell] = is_solid
	)


func _process(delta):
	if !_update_nodes:
		return

	_update_nodes = false

	for cell: Cell in _node_update_dict.keys():
		astar_grid.set_point_solid(Vector2i(cell.x, cell.y), _node_update_dict[cell])
		pathfinding_grid_was_modified.emit()

	_node_update_dict.clear()


func initialize_grid(width: int, height: int):
	cell_size = Vector2i(16, 16)
	grid_size = Vector2i(width, height)

	astar_grid.region.size = grid_size
	astar_grid.cell_size = cell_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar_grid.update()

	queue_redraw()


func _get_walkable_neighbour(cell: Cell) -> Cell:
	var neighbours = MapUtilities.get_cell_neighbours(cell)
	neighbours.shuffle()

	for neighbour in neighbours:
		if is_point_walkable(neighbour.scene_position):
			return neighbour

	return null


func get_path_from_cell_to_cell(start_cell: Cell, end_cell: Cell) -> PackedVector2Array:
	# NOTE: this is not sufficient because walkable neighbour may not be the closest point
	# to the agent.
	if !is_point_walkable(end_cell.scene_position):
		#print_debug("End cell isn't walkable")

		end_cell = _get_walkable_neighbour(end_cell)

		if !end_cell:
			return []
			#print_debug("No end cell could be found")

	#var a_1 = [start_cell, end_cell]
	#var a_2 = [start_cell, end_cell]
	#
	#print_debug(a_1 == a_2)		# TRUE

	if cell_path_dict.has(start_cell):
		# Verify path
		for node in cell_path_dict[start_cell]:
			# NOTE: we must divide by the 'cell size'
			if !is_point_walkable(node):
				print_debug("Previously valid path now has solid node. Getting a new path")
				return _get_new_path(start_cell, end_cell)

		return cell_path_dict[start_cell]

	return _get_new_path(start_cell, end_cell)


func is_point_walkable(node_scene_position: Vector2i) -> bool:
	return !astar_grid.is_point_solid(node_scene_position / GameConstants.PIXEL_SCALE)


func _get_path_key(start_cell: Cell, end_cell: Cell):
	return hash(str(start_cell.i, "_", end_cell.i))


func _get_new_path(start_cell: Cell, end_cell: Cell) -> PackedVector2Array:
	var path = astar_grid.get_point_path(start_cell.position, end_cell.position)
	cell_path_dict[start_cell] = path

	return path


func _draw():
	if not draw_pathfinding_grid:
		return

	draw_grid()


func draw_grid():
	for x in grid_size.x + 1:
		draw_line(Vector2(x * cell_size.x, 0) + offset,
			Vector2(x * cell_size.x, grid_size.y * cell_size.y) + offset,
			Color.CORAL, .5)

	for y in grid_size.y + 1:
		draw_line(Vector2(0, y * cell_size.y) + offset,
			Vector2(grid_size.x * cell_size.x, y * cell_size.y) + offset,
			Color.CORAL, .5)
