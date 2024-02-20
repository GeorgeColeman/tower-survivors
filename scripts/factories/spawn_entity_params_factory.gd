class_name SpawnEntityParamsFactory

static func new_spawn_entity_params(
	scene: PackedScene,
	cell: Cell
) -> SpawnEntityParams:
	var spawn_entity_params = SpawnEntityParams.new()

	spawn_entity_params.entity_scene = scene
	spawn_entity_params.cell = cell

	return spawn_entity_params
