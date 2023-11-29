extends Node

var game_is_set: bool:
	get:
		return _game != null

var _game_manager: GameManager
var _game: Game


func set_game_manager(game_manager: GameManager):
	_game_manager = game_manager


func set_game(game: Game):
	_game = game


func get_point_path(start, end) -> PackedVector2Array:
	return _game_manager.pathfinding_manager.astar_grid.get_point_path(start, end)


func get_distance_between_nodes(node_a: Vector2i, node_b: Vector2i) -> float:
	var cell_a = get_cell_at_vector2i(node_a)
	var cell_b = get_cell_at_vector2i(node_b)

	return get_distance_between_cells(cell_a, cell_b)


func get_distance_between_cells(cell_a: Cell, cell_b: Cell) -> float:
	var steps = abs(cell_a.x - cell_b.x) + abs(cell_a.y - cell_b.y)
#
	if steps == 1:
		return 1.0

	return 1.4


func get_cells_in_circle(centre_cell: Cell, radius: float) -> Array[Cell]:
	return _game.map.get_cells_in_circle(centre_cell, radius)


func get_cells_in_circle_sorted_by_distance_from(origin_cell: Cell, radius: float) -> Array[Cell]:
	var cells_in_circle = _game.map.get_cells_in_circle(origin_cell, radius)

	cells_in_circle.sort_custom(
		func(cell_a: Cell, cell_b: Cell):
			return origin_cell.position.distance_squared_to(cell_a.position) < origin_cell.position.distance_squared_to(cell_b.position)
	)

	return cells_in_circle


func get_mob_targets(origin_cell: Cell, cells_in_range: Array[Cell],number_of_targets: int) -> Array[Mob]:
	var all_mobs = _game.mob_spawner.get_mob_targets(cells_in_range)

	if number_of_targets >= all_mobs.size():
		return all_mobs

	return all_mobs.slice(0, number_of_targets)


func get_cell_at_vector2i(vector: Vector2i) -> Cell:
	return _game.map.get_cell_at_world(vector.x, vector.y)


func get_cell_at(vector: Vector2) -> Cell:
	var x = floori((vector.x + 8) / 16)
	var y = floori((vector.y + 8) / 16)
	return _game.map.get_cell_at(x, y)


func get_world_position_of_cell(cell: Cell) -> Vector2i:
	return cell.position * 16


func get_actors_at(cell: Cell) -> Array:
	var all_actors = []

	var towers = _game_manager.tower_spawner.get_towers_at(cell)
	all_actors.append_array(towers)

	return all_actors


func get_upgrade_options(amount: int) -> UpgradeOptions:
	var options = Utilities.get_random_unique_elements(_game.game_data.upgrade_resources, 3)

	return UpgradeOptions.new(options)


func calculate_sprite_offset(sprite_2d: Sprite2D) -> Vector2:
	var rect = sprite_2d.get_rect()
	return -Vector2(
		(rect.size.x - GameConstants.PIXEL_SCALE) * 0.5,
		(rect.size.y - GameConstants.PIXEL_SCALE) * 0.5)

