extends Node

signal control_mode_build_requested(option: BuildingOption)

var game_is_set: bool:
	get:
		return _game != null

var _game: Game


func set_game(game: Game):
	_game = game


func try_enter_build_mode(option: BuildingOption):
	if !_game.player.can_afford_building_option(option):
		return

	option.try_build_callback = func(cell: Cell):
		if !_game.player.can_afford_building_option(option):
				return

		# Check cell for existing buildings
		if _game.towers.get_is_cell_occupied(cell):
			print_debug("Cell is occupied")

			return

		# Check cell 'buildability'
		if !PathUtilities.get_is_cell_walkable(cell):
			print_debug("Cell is solid, cannot build")

			return

		var params = SpawnEntityParamsFactory.new_spawn_entity_params(
			option.tower_resource.tower_scene,
			cell,
			option.tower_resource.base_area
		)

		_game.towers.spawn_tower(option.tower_resource, params, option._rank)
		_game.player.spend_resources_for_building(option)

		option.confirm_build()

	control_mode_build_requested.emit(option)


func get_distance_between_nodes(node_a: Vector2i, node_b: Vector2i) -> float:
	var steps = abs(node_a.x - node_b.x) + abs(node_a.y - node_b.y)

	if steps == 1:
		return 1.0

	return 1.4


func get_tower_weapon_description(tower_resource: TowerResource) -> String:
	if tower_resource.weapons.size() == 0:
		return ""

	var first_weapon = _game.game_data.get_tower_weapon_data(
		tower_resource.weapons[0]
	)

	if !first_weapon:
		return ""

	return first_weapon.get_description()


func highlight_building_cells(centre_cell: Cell, building_option: BuildingOption):
	if building_option.tower_resource.weapons.size() == 0:
		return

	var first_weapon = _game.game_data.get_tower_weapon_data(
		building_option.tower_resource.weapons[0]
	)

	if !first_weapon:
		return

	_highlight_cells_in_tower_weapon_attack_range(centre_cell, first_weapon)


func _highlight_cells_in_tower_weapon_attack_range(centre_cell: Cell, tower_weapon_data: TowerWeaponData):
	var attack_range = tower_weapon_data.attack_range

	Messenger.draw_cell_area_requested.emit(
		get_cells_in_circle(centre_cell, attack_range)
	)


func get_cells_in_circle(centre_cell: Cell, radius: float) -> Array[Cell]:
	return _game.map.get_cells_in_circle(centre_cell, radius)


func get_cells_in_circle_sorted_by_distance_from(origin_cell: Cell, radius: float) -> Array[Cell]:
	var cells_in_circle = _game.map.get_cells_in_circle(origin_cell, radius)

	cells_in_circle.sort_custom(
		func(cell_a: Cell, cell_b: Cell):
			return origin_cell.position.distance_squared_to(cell_a.position) < origin_cell.position.distance_squared_to(cell_b.position)
	)

	return cells_in_circle


func get_cells_in_radius_from_base(
	radius: float,
	base: Array[Cell]
	) -> Array[Cell]:
	var cells_in_radius = _game.map.get_cells_in_radius_from_base(radius, base)

	return cells_in_radius



func get_all_targets_in_cells(cells: Array[Cell]) -> Array[Mob]:
	return _game.mob_spawner.get_mob_targets(cells)


func get_mob_targets(cells_in_range: Array[Cell], number_of_targets: int) -> Array[Mob]:
	var all_mobs = _game.mob_spawner.get_mob_targets(cells_in_range)

	if number_of_targets >= all_mobs.size():
		return all_mobs

	return all_mobs.slice(0, number_of_targets)


func get_mob_targets_closest_to_main_tower(
	cells_in_range: Array[Cell],
	number_of_targets: int
	) -> Array[Mob]:
	var all_mobs = _game.mob_spawner.get_mob_targets(cells_in_range)

	if number_of_targets >= all_mobs.size():
		return all_mobs

	if !_game.main_tower:
		return []

	all_mobs.sort_custom(
		func(mob_a: Mob, mob_b: Mob):
			var dist_a = mob_a.position.distance_squared_to(_game.main_tower.position)
			var dist_b = mob_b.position.distance_squared_to(_game.main_tower.position)
			return dist_b > dist_a
			#return dist_a > dist_b
	)

	return all_mobs.slice(0, number_of_targets)


func get_entity_info_at(cell: Cell) -> Array[EntityInfo]:
	var all_entities: Array[EntityInfo] = []

	for tower in _game.towers.get_towers_at(cell):
		all_entities.append(tower.get_entity_info())

	var spawn_points = MobUtilities.get_spawn_points_at(cell)

	for spawn_point in spawn_points:
		all_entities.append(spawn_point.get_entity_info())

	return all_entities


func calculate_sprite_offset(sprite_2d: Sprite2D) -> Vector2:
	var rect = sprite_2d.get_rect()
	return -Vector2(
		(rect.size.x - GameConstants.PIXEL_SCALE) * 0.5,
		(rect.size.y - GameConstants.PIXEL_SCALE) * 0.5)


func get_nearby_tower(cell: Cell) -> Tower:
	var neighbours = _game.map.get_cell_neighbours(cell)

	for n_cell in neighbours:
		for tower in _game.towers.get_towers_at(n_cell):
			return tower

	return null


func get_scene_position(cell: Cell, base_area: Vector2i) -> Vector2:
	if base_area.x != base_area.y:
		print_debug("WARNING: tower base area is not a square. Returning empty vector")

		return Vector2.ZERO

	if base_area.x * base_area.y == 1:
		return cell.scene_position

	return cell.scene_position + Vector2(
		(base_area.x - 1) * 0.5,
		(base_area.y - 1) * 0.5,
	) * GameConstants.PIXEL_SCALE
