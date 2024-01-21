class_name EntityDrawer
extends Node2D


var _tower_dict = {}					# <String, Array[Tower]>
var _drawn_entities: Array[Node2D] = []


func set_game(game: Game):
	game.entities.entity_added.connect(_on_requested_spawn_entity)
	game.building_options.option_upgraded.connect(_on_building_option_upgraded)

	_erase_existing()


# CURSED
func _on_building_option_upgraded(option: BuildingOption):
	if !GameRules.UPGRADE_EXISTING:
		return

	# No towers of this type exist yet
	if !_tower_dict.has(option.name):
		return

	for tower in _tower_dict[option.name]:
		tower.add_rank(1)


func _on_requested_spawn_entity(params: SpawnEntityParams):
	var new_entity = params.entity_scene.instantiate()

	params.entity_instantiated.emit(new_entity)

	params.spawned_entity = new_entity

	if new_entity is Node2D:
		_spawn_node(new_entity, params.cell)

		if new_entity is Tower:
			_register_as_tower(new_entity)
	else:
		print_debug("WARNING: scene is not of type Node2D")


func _spawn_node(node_2d: Node2D, cell: Cell):
	add_child(node_2d)
	_drawn_entities.append(node_2d)

	node_2d.position = cell.scene_position


func _register_as_tower(tower: Tower):
	if !_tower_dict.has(tower.tower_name):
		_tower_dict[tower.tower_name] = [tower]
	else:
		_tower_dict[tower.tower_name].append(tower)

	tower.was_killed.connect(
		func():
			tower.queue_free()
	)


func _erase_existing():
	for entity in _drawn_entities:
		entity.queue_free()
