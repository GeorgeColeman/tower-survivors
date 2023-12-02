class_name Pathfinding
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


func _process(delta):
	if !_update_nodes:
		return

	_update_nodes = false

	for cell: Cell in _node_update_dict.keys():
		astar_grid.set_point_solid(Vector2i(cell.x, cell.y), _node_update_dict[cell])
		pathfinding_grid_was_modified.emit()

	_node_update_dict.clear()


func add_node_update(cell: Cell, is_solid: bool):
	_update_nodes = true
	_node_update_dict[cell] = is_solid


func initialize_grid(width: int, height: int):
	cell_size = Vector2i(16, 16)
	grid_size = Vector2i(width, height)

	astar_grid.region.size = grid_size
	astar_grid.cell_size = cell_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar_grid.update()

	queue_redraw()


func get_path_from_cell_to_cell(start_cell: Cell, end_cell: Cell) -> PackedVector2Array:
	if cell_path_dict.has(start_cell):
		# Verify path
		for node in cell_path_dict[start_cell]:
			# NOTE: we must divide by the 'cell size'
			if astar_grid.is_point_solid(node / GameConstants.PIXEL_SCALE):
				print_debug("Previously valid path now has solid node. Getting a new path")
				return _get_new_path(start_cell, end_cell)

		return cell_path_dict[start_cell]

	return _get_new_path(start_cell, end_cell)


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
