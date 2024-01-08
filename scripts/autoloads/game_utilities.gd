extends Node

signal control_mode_build_requested(option: BuildingOption)

var game_is_set: bool:
	get:
		return _game != null

var _game_manager: GameManager
var _game: Game


func set_game_manager(game_manager: GameManager):
	_game_manager = game_manager


func set_game(game: Game):
	_game = game


func try_enter_build_mode(option: BuildingOption):
	if !_game.player.can_afford_building_option(option):
		return

	option.on_build_confirmed = func(cell: Cell):
		if !_game.player.can_afford_building_option(option):
				return

		# Check cell for existing buildings
		if _game.entities.get_is_cell_occupied(cell):
			print_debug("Cell is occupied")
			return

		var params = SpawnEntityParams.new()

		params.entity_scene = option.scene
		params.cell = cell

		_game.entities.spawn_entity(params)

		# HACK: we're doing this here because this is the only place we know
		# about the spawned entity and the building option, which enables us
		# to set the rank
		if params.spawned_entity is Tower:
			params.spawned_entity.set_rank(option.rank)

		_game.player.spend_resources_for_building(option)

	control_mode_build_requested.emit(option)


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


func get_mob_targets(cells_in_range: Array[Cell], number_of_targets: int) -> Array[Mob]:
	var all_mobs = _game.mob_spawner.get_mob_targets(cells_in_range)

	if number_of_targets >= all_mobs.size():
		return all_mobs

	return all_mobs.slice(0, number_of_targets)


func get_entity_info_at(cell: Cell) -> Array[EntityInfo]:
	var all_entities: Array[EntityInfo] = []

	var entities = _game.entities.get_entities_at(cell)
	#all_entities.append_array(entities)

	for entity in entities:
		if entity is Tower:
			all_entities.append(
				EntityInfo.new(entity, entity.tower_name, entity.description, entity.position)
			)

	var spawn_points = _game_manager.mob_spawner.get_spawn_points_at(cell)
	#all_entities.append_array(spawn_points)

	for spawn_point in spawn_points:
		all_entities.append(
			EntityInfo.new(
				spawn_point,
				 "Spawn Point",
				 "TODO: spawn point description",
				 spawn_point.position
			)
		)

	return all_entities


func calculate_sprite_offset(sprite_2d: Sprite2D) -> Vector2:
	var rect = sprite_2d.get_rect()
	return -Vector2(
		(rect.size.x - GameConstants.PIXEL_SCALE) * 0.5,
		(rect.size.y - GameConstants.PIXEL_SCALE) * 0.5)

