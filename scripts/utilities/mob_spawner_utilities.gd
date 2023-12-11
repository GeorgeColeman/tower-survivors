class_name MobSpawnerUtilities
extends RefCounted

static var _instance: MobSpawnerUtilities

var _mob_spawner: MobSpawner


func _init(mob_spawner: MobSpawner):
	_instance = self
	_mob_spawner = mob_spawner


static func spawn_mobs_in_random_neighbouring_tiles(mob_resource: MobResource, number: int, cell: Cell):
	for i in number:
		var neighbours = _instance._mob_spawner._map.get_cell_neighbours(cell)

		_instance._mob_spawner.spawn_mob(
			mob_resource,
			neighbours[randi_range(0, neighbours.size() - 1)]
		)

	#print_debug("TODO: spawn mobs using instance member: ", _instance._mob_spawner)
	pass

