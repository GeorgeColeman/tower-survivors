class_name PathfindingManager
extends Node2D

signal pathfinding_grid_was_modified()

@export var create_obstacles_on_click: bool

@onready var mob_path_lines_container = $MobPathLinesContainer

var astar_grid = AStarGrid2D.new()
var grid_size: Vector2i
var cell_size: Vector2i
var offset: Vector2
var cell_path_dict = {}

var _find_existing_path: bool = false

# <Cell, bool>
var _node_update_dict = {}
var _update_nodes = false

var _walkable_regions: WalkableRegions
var _initial_walkable_regions_established: bool


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


func _process(_delta):
	if !_update_nodes:
		return

	_update_nodes = false

	for cell: Cell in _node_update_dict.keys():
		astar_grid.set_point_solid(Vector2i(cell.x, cell.y), _node_update_dict[cell])
		pathfinding_grid_was_modified.emit()

	_node_update_dict.clear()

	if _initial_walkable_regions_established:
		return

	_initial_walkable_regions_established = true

	update_walkable_regions()


func initialize_grid(width: int, height: int, pixel_scale: int):
	cell_size = Vector2i(pixel_scale, pixel_scale)
	grid_size = Vector2i(width, height)
	offset = -Vector2.ONE * .5 * pixel_scale

	astar_grid.region.size = grid_size
	astar_grid.cell_size = cell_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar_grid.update()

	queue_redraw()


func update_walkable_regions():
	var get_is_walkable = func(x: int, y: int) -> bool:
		return !astar_grid.is_point_solid(Vector2i(x, y))
		#return _is_point_within_grid(x, y) && !astar_grid.is_point_solid(Vector2i(x, y))

	_walkable_regions = WalkableRegions.new(
		grid_size.x,
		grid_size.y,
		get_is_walkable)

	_walkable_regions.establish_regions()
	
	PathUtilities.walkable_regions_updated.emit(_walkable_regions)


#func _is_point_within_grid(x: int, y: int) -> bool:
	#if x < 0 || x >= grid_size.x || y < 0 || y >= grid_size.y:
		#return false
#
	#return true


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

	if !_find_existing_path:
		return _get_new_path(start_cell, end_cell)

	if cell_path_dict.has(start_cell):
		# Verify path
		for node in cell_path_dict[start_cell]:
			# NOTE: we must divide by the 'cell size'
			if !is_point_walkable(node):
				print_debug("Previously valid path now has solid node. Getting a new path")
				return _get_new_path(start_cell, end_cell)

		return cell_path_dict[start_cell]

	return _get_new_path(start_cell, end_cell)


func is_cell_walkable(cell: Cell) -> bool:
	return !astar_grid.is_point_solid(cell.position)


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
	var walkable_colour: Color = Color.GREEN
	walkable_colour.a = 0.5
	var unwalkable_colour: Color = Color.RED
	unwalkable_colour.a = 0.5

	for y in grid_size.y:
		for x in grid_size.x:
			var is_walkable = !astar_grid.is_point_solid(Vector2i(x, y))
			var color = walkable_colour if is_walkable else unwalkable_colour
			draw_circle(Vector2(x * cell_size.x, y * cell_size.y), 5, color)

	for x in grid_size.x + 1:
		draw_line(Vector2(x * cell_size.x, 0) + offset,
			Vector2(x * cell_size.x, grid_size.y * cell_size.y) + offset,
			Color.CORAL, .5)

	for y in grid_size.y + 1:
		draw_line(Vector2(0, y * cell_size.y) + offset,
			Vector2(grid_size.x * cell_size.x, y * cell_size.y) + offset,
			Color.CORAL, .5)
