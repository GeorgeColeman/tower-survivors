class_name EntityDrawer
extends Node2D

# <Cell, Array[Node2D]>
var _cell_entity_dict = {}


func _ready():
	Entities.spawn_entity_requested.connect(_on_requested_spawn_entity)


func set_game(game: Game):
	_erase_existing()


func get_entities_at(cell: Cell) -> Array:
	if !_cell_entity_dict.has(cell):
		return []

	return _cell_entity_dict[cell]


func _on_requested_spawn_entity(params: SpawnEntityParams):
	var new_entity = params.entity_scene.instantiate()

	if new_entity is Node2D:
		var cell = params.cell

		add_child(new_entity)

		new_entity.position = cell.scene_position

		if !_cell_entity_dict.has(cell):
			_cell_entity_dict[cell] = []

		_cell_entity_dict[cell].append(new_entity)

		# TEMP: assuming all new entities are solid
		PathUtilities.updated_cell_is_solid.emit(cell, true)

		# Special case if entity is a tower
		if new_entity is Tower:
			new_entity.set_cell_and_init(cell)

			new_entity.was_killed.connect(
				func():
					_cell_entity_dict[cell].erase(new_entity)
					PathUtilities.updated_cell_is_solid.emit(cell, false)
					new_entity.queue_free()
			)
	else:
		print_debug("WARNING: scene is not of type Node2D")


func _erase_existing():
	for entities in _cell_entity_dict.values():
		for entity in entities:
			entity.queue_free()

	_cell_entity_dict.clear()

	_cell_entity_dict.clear()
