class_name EntityDrawer
extends Node2D

# <Cell, Array[Node2D]>
var _cell_entity_dict = {}

# <String, Array[Tower]>
var _tower_dict = {}


func _ready():
	Entities.entity_added.connect(_on_requested_spawn_entity)


func set_game(game: Game):
	# A hacky way of ensuring the Entities utility autoload class has access to the entity dictionary
	Entities.set_cell_entity_dict(_cell_entity_dict)

	game.building_options.option_upgraded.connect(_on_building_option_upgraded)

	_erase_existing()


func _on_building_option_upgraded(option: BuildingOption):
	if !GameRules.UPGRADE_EXISTING:
		return

	# No towers of this type exist yet
	if !_tower_dict.has(option.name):
		return

	for tower in _tower_dict[option.name]:
		tower.add_rank(1)


func get_entities_at(cell: Cell) -> Array:
	if !_cell_entity_dict.has(cell):
		return []

	return _cell_entity_dict[cell]


func _on_requested_spawn_entity(params: SpawnEntityParams):
	var new_entity = params.entity_scene.instantiate()

	#new_entity = new_entity.duplicate()

	params.spawned_entity = new_entity

	if new_entity is Node2D:
		_spawn_node(new_entity, params.cell)

		if new_entity is Tower:
			_register_as_tower(new_entity, params.cell)
	else:
		print_debug("WARNING: scene is not of type Node2D")


func _spawn_node(node_2d: Node2D, cell: Cell):
	add_child(node_2d)

	node_2d.position = cell.scene_position

	if !_cell_entity_dict.has(cell):
		_cell_entity_dict[cell] = []

	_cell_entity_dict[cell].append(node_2d)

	# TEMP: assuming all new entities are solid
	PathUtilities.updated_cell_is_solid.emit(cell, true)


func _register_as_tower(tower: Tower, cell: Cell):
	if !_tower_dict.has(tower.tower_name):
		_tower_dict[tower.tower_name] = [tower]
	else:
		_tower_dict[tower.tower_name].append(tower)

	tower.init_weapons()
	tower.set_cell_and_init(cell)

	tower.was_killed.connect(
		func():
			_cell_entity_dict[cell].erase(tower)
			PathUtilities.updated_cell_is_solid.emit(cell, false)
			tower.queue_free()
	)


func _erase_existing():
	for entities in _cell_entity_dict.values():
		for entity in entities:
			entity.queue_free()

	_cell_entity_dict.clear()

	_cell_entity_dict.clear()
