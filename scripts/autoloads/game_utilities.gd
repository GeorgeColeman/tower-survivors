extends Node

#signal on_set_game(game: Game)
signal control_mode_build_requested(buildable_object_data: BuildableObjectData)

var game_is_set: bool:
	get:
		return _game != null

var _game_manager: GameManager
var _game: Game


func set_game_manager(game_manager: GameManager):
	_game_manager = game_manager


func set_game(game: Game):
	_game = game

	#on_set_game.emit(game)


func try_enter_build_mode(buildable_object_data: BuildableObjectData):
	var check_gold = func() -> bool:
		var has_enough_gold = _game.tower.current_gold >= buildable_object_data.gold_cost

		if !has_enough_gold:
			print_debug("Not enough gold")

		return has_enough_gold

	if !check_gold.call():
		return

	buildable_object_data.on_build_confirmed = func(cell: Cell):
		if !check_gold.call():
			return
			
		var params = SpawnEntityParams.new()

		params.entity_scene = buildable_object_data.scene
		params.cell = cell

		Entities.spawn_entity(params)
		
		_game.tower.add_gold(-buildable_object_data.gold_cost)

	control_mode_build_requested.emit(buildable_object_data)



func get_point_path(start, end) -> PackedVector2Array:
	return _game_manager.pathfinding_manager.astar_grid.get_point_path(start, end)


func get_path_from_cell_to_cell(start_cell: Cell, end_cell: Cell) -> PackedVector2Array:
	return _game_manager.pathfinding_manager.get_path_from_cell_to_cell(start_cell, end_cell)


func get_distance_between_nodes(node_a: Vector2i, node_b: Vector2i) -> float:
	var steps = abs(node_a.x - node_b.x) + abs(node_a.y - node_b.y)

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


func get_entities_at(cell: Cell) -> Array:
	var all_entities = []

	var towers = _game_manager.tower_spawner.get_towers_at(cell)
	all_entities.append_array(towers)

	var entities = _game_manager.entity_drawer.get_entities_at(cell)
	all_entities.append_array(entities)

	var spawn_points = _game_manager.mob_spawner.get_spawn_points_at(cell)
	all_entities.append_array(spawn_points)

	return all_entities


func get_upgrade_options(amount: int) -> UpgradeOptions:
	var options = Utilities.get_random_unique_elements(_game.game_data.upgrade_resources, 3)

	return UpgradeOptions.new(options)


func calculate_sprite_offset(sprite_2d: Sprite2D) -> Vector2:
	var rect = sprite_2d.get_rect()
	return -Vector2(
		(rect.size.x - GameConstants.PIXEL_SCALE) * 0.5,
		(rect.size.y - GameConstants.PIXEL_SCALE) * 0.5)

