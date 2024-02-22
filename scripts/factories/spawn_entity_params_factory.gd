class_name SpawnEntityParamsFactory

static func new_spawn_entity_params(
	scene: PackedScene,
	cell: Cell,
	base_area: Vector2i
) -> SpawnEntityParams:
	var spawn_entity_params = SpawnEntityParams.new()

	spawn_entity_params.entity_scene = scene
	spawn_entity_params.cell = cell
	spawn_entity_params.base_area = base_area

	return spawn_entity_params
