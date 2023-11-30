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


var draw_pathfinding_grid = false:
	set(value):
		draw_pathfinding_grid = value
		queue_redraw()

var draw_mob_paths = false:
	set(value):
		draw_mob_paths = value
		mob_path_lines_container.visible = value


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
#		print_debug("Using existing path")
		return cell_path_dict[start_cell]

#	print_debug("Getting new path")
	var path = astar_grid.get_point_path(start_cell.position, end_cell.position)
	cell_path_dict[start_cell] = path
	return path


func _input(event):
	if !create_obstacles_on_click:
		return

	if event is InputEventMouseButton:
		if cell_size == Vector2i.ZERO:
			return
		# Add/remove wall
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var global_mouse_pos = get_global_mouse_position() - offset
			var pos = Vector2i(global_mouse_pos) / cell_size
#			var pos = Vector2i(event.position) / cell_size

			if astar_grid.is_in_boundsv(pos):
				astar_grid.set_point_solid(pos, not astar_grid.is_point_solid(pos))
				pathfinding_grid_was_modified.emit()
#				_get_paths_from_spawn_points_to_tower()

			queue_redraw()


func _draw():
	if not draw_pathfinding_grid:
		return

	draw_grid()
	_fill_walls()


func draw_grid():
	for x in grid_size.x + 1:
		draw_line(Vector2(x * cell_size.x, 0) + offset,
			Vector2(x * cell_size.x, grid_size.y * cell_size.y) + offset,
			Color.CORAL, .5)

	for y in grid_size.y + 1:
		draw_line(Vector2(0, y * cell_size.y) + offset,
			Vector2(grid_size.x * cell_size.x, y * cell_size.y) + offset,
			Color.CORAL, .5)


func _fill_walls():
	for x in grid_size.x:
		for y in grid_size.y:
			if astar_grid.is_point_solid(Vector2i(x, y)):
				draw_rect(Rect2(x * cell_size.x + offset.x, y * cell_size.y + offset.y, cell_size.x, cell_size.y), Color.DARK_GRAY)
