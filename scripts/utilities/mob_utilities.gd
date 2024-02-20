class_name MobUtilities

static var _mob_spawner: MobSpawner
static var _spawn_point_manager: SpawnPointManager


static func init(mob_spawner: MobSpawner, spawn_point_manager: SpawnPointManager):
	_mob_spawner = mob_spawner
	_spawn_point_manager = spawn_point_manager


static func get_spawn_points_at(cell: Cell) -> Array:
	return _spawn_point_manager.get_spawn_points_at(cell)


static func get_random_spawn_point() -> MobCamp:
	return _spawn_point_manager.get_random_spawn_point()


static func spawn_mob_at(mob_resource: MobResource, spawn_point: MobCamp):
	_mob_spawner.spawn_mob_at(mob_resource, spawn_point)


static func spawn_mobs_in_random_neighbouring_tiles(
	mob_resource: MobResource,
	number: int,
	p_cell: Cell
) -> Array[Mob]:
	var mobs: Array[Mob] = []
	var neighbours = _mob_spawner._map.get_cell_neighbours(p_cell)

	# Filter: https://github.com/godotengine/godot/pull/38645
	neighbours.filter(
		func(cell: Cell):
			return PathUtilities.get_is_cell_walkable(cell)
	)

	for i in number:
		mobs.append(_mob_spawner.spawn_mob(
			mob_resource,
			neighbours.pick_random()
		))

	return mobs


static func get_mobs_at(cell: Cell) -> Array[Mob]:
	return _mob_spawner.get_mobs_at(cell)
