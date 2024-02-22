class_name EntityDrawer
extends Node2D

var _drawn_entities: Array[Node2D] = []


func set_game(game: Game):
	game.entities.entity_added.connect(_on_requested_spawn_entity)

	_erase_existing()


func _on_requested_spawn_entity(params: SpawnEntityParams):
	var new_entity = params.entity_scene.instantiate()

	params.entity_instantiated.emit(new_entity)

	params.spawned_entity = new_entity

	if new_entity is Node2D:
		_spawn_node(new_entity, GameUtilities.get_scene_position(params.cell, params.base_area))
		params.entity_destroyed.connect(
			func(entity):
				new_entity.queue_free()
		)
	else:
		print_debug("WARNING: scene is not of type Node2D")


func _spawn_node(node_2d: Node2D, position: Vector2):
	add_child(node_2d)
	_drawn_entities.append(node_2d)

	node_2d.position = position


func _erase_existing():
	for entity in _drawn_entities:
		entity.queue_free()
