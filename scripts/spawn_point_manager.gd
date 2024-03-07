class_name SpawnPointManager
extends Node2D

@export var _spawn_point_scene: PackedScene
@export var _starting_spawn_points: int = 1
@export var _next_spawn_point: PackedScene
@export var _debug_draw_valid_spawn_points: bool:
	set(value):
		_debug_draw_valid_spawn_points = value

		queue_redraw()

var _cell_spawn_point_dict = {}

var _valid_spawn_point_cells: Array[Cell] = []
var _next_spawn_point_dict = {}						# <Cell, Sprite2D>

var _game: Game


func _draw():
	if !_debug_draw_valid_spawn_points:
		return

	for point in _valid_spawn_point_cells:
		draw_circle(point.scene_position, 8, Color.ORANGE)


func start_game(game: Game):
	_game = game

	_erase_existing()

	if !GameRules.USE_SPAWN_POINTS:
		return

	game.difficulty.changed.connect(
		func(_difficulty: int):
			spawn_new_spawn_point()
	)

	# HACK: because path nodes don't seem to be properly updated yet
	await get_tree().create_timer(0.1).timeout

	_get_valid_spawn_points(game.map.width, game.map.height, game.main_tower.cell.position)

	for spawn_point in _starting_spawn_points:
		spawn_new_spawn_point()


func get_spawn_points_at(cell: Cell) -> Array:
	if !_cell_spawn_point_dict.has(cell):
		return []

	return [_cell_spawn_point_dict[cell]]


func get_random_spawn_point() -> MobCamp:
	return _cell_spawn_point_dict.values().pick_random()


func spawn_new_spawn_point():
	var next: Cell

	if _next_spawn_point_dict.size() == 0:
		next = _get_valid_spawn_point_cell()
	else:
		next = _next_spawn_point_dict.keys().pick_random()
		_next_spawn_point_dict[next].queue_free()
		_next_spawn_point_dict.erase(next)

	var new_spawn_point = _spawn_point_scene.instantiate() as MobCamp
	add_child(new_spawn_point)

	new_spawn_point.set_resource(_game.game_data.get_random_mob_camp_resource())
	new_spawn_point.set_mob_pool(_game.game_data)

	new_spawn_point.cell = next
	new_spawn_point.position = next.scene_position
	_cell_spawn_point_dict[next] = new_spawn_point

	Messenger.create_alert("New enemy camp appeared!")

	_set_next_spawn_point()


func _set_next_spawn_point():
	var next_cell = _get_valid_spawn_point_cell()
	var next_marker = _next_spawn_point.instantiate()

	_next_spawn_point_dict[next_cell] = next_marker

	add_child(next_marker)

	next_marker.position = next_cell.scene_position


func _get_valid_spawn_point_cell() -> Cell:
	var cells = Array(_valid_spawn_point_cells)
	cells.shuffle()

	for cell in cells:
		if _cell_spawn_point_dict.has(cell):
			print_debug("Spawn point already exists at: ", cell)
			continue

		return cell

	print_debug("WARNING: unable to find valid spawn point cell. Returning null")

	return null


func _get_valid_spawn_points(width: int, height: int, centre: Vector2):
	var poisson_points = PoissonDiscSampling.generate_points_for_polygon(
		PackedVector2Array(
			[Vector2(0, 0),
			Vector2(0, height),
			Vector2(width, height),
			Vector2(width, 0)]
		),
		3,
		30
	)

	var min_dist_from_tower_sqr = 10 * 10

	for point in poisson_points:
		var cell = MapUtilities.get_cell_at_map_position(point)

		if !PathUtilities.get_is_cell_walkable(cell):
			continue

		if cell:
			var dist_from_tower = cell.position.distance_squared_to(centre)

			if dist_from_tower > min_dist_from_tower_sqr:
				_valid_spawn_point_cells.append(cell)

	#print_debug("Found %s valid spawn points" % _valid_spawn_point_cells.size())

	queue_redraw()


func _erase_existing():
	for spawn_point in _cell_spawn_point_dict.values():
		spawn_point.queue_free()

	_cell_spawn_point_dict.clear()
