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

	#on_set_game.emit(game)


func try_enter_build_mode(option: BuildingOption):
	var check_gold = func() -> bool:
		var has_enough_gold = _game.player.current_gold >= option.gold_cost

		if !has_enough_gold:
			print_debug("Not enough gold")

		return has_enough_gold

	if !check_gold.call():
		return

	option.on_build_confirmed = func(cell: Cell):
		if !check_gold.call():
			return

		# Check cell for existing buildings
		if Entities.get_is_cell_occupied(cell):
			print_debug("Cell is occupied")
			return

		var params = SpawnEntityParams.new()

		params.entity_scene = option.scene
		params.cell = cell

		#_game_manager.entity_drawer._on_requested_spawn_entity(params)

		Entities.spawn_entity(params)

		# HACK: we're doing this here because this is the only place we know
		# about the spawned entity and the building option, which enables us
		# to set the rank
		if params.spawned_entity is Tower:
			params.spawned_entity.set_rank(option.rank)

		_game.player.add_gold(-option.gold_cost)

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


func get_mob_targets(cells_in_range: Array[Cell],number_of_targets: int) -> Array[Mob]:
	var all_mobs = _game.mob_spawner.get_mob_targets(cells_in_range)

	if number_of_targets >= all_mobs.size():
		return all_mobs

	return all_mobs.slice(0, number_of_targets)


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
	var options = Utilities.get_random_unique_elements(_game.game_data.upgrade_resources, amount)

	return UpgradeOptions.new(options)


func generate_upgrade_options(amount: int) -> UpgradeOptions:
	var options: Array[UpgradeOption] = []

	for upgrade in _game.game_data.upgrade_resources:
		options.append(
			UpgradeOption.new(
				upgrade.name,
				func():
					upgrade.add_to_tower(_game.tower)
		)
		)

	for tower in _game.game_data.towers:
		var unpacked_tower = tower.instantiate() as Tower

		# Check if the building option already exists
		var existing_option = _game.building_options.get_building_option(tower)

		if existing_option:
			options.append(
				UpgradeOption.new(
					"*UPGRADE* %s" % unpacked_tower.name,
					func(): existing_option.upgrade()
				)
			)

			continue

		options.append(
			UpgradeOption.new(
				unpacked_tower.name,
				func():
					_game.building_options.add_building_option_packed(tower)
		)
		)

	return UpgradeOptions.new(
		Utilities.get_random_unique_elements(
			options,
			amount
		)
	)


func calculate_sprite_offset(sprite_2d: Sprite2D) -> Vector2:
	var rect = sprite_2d.get_rect()
	return -Vector2(
		(rect.size.x - GameConstants.PIXEL_SCALE) * 0.5,
		(rect.size.y - GameConstants.PIXEL_SCALE) * 0.5)

