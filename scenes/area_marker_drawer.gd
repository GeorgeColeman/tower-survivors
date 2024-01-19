extends Node2D

@export var _marker_texture: Texture2D

var _markers: Array[Sprite2D]


func _ready():
	SelectionManager.entity_selected.connect(
		func(entity_info: EntityInfo):
			print_debug("TEMP: we need a more intelligent way of detecting when a tower is selected")
			if entity_info.entity is Tower:
				draw_cell_area_markers(entity_info.entity.get_cells_in_attack_range())
			else:
				clear_markers()
	)

	SelectionManager.selection_cleared.connect(
		func():
			clear_markers()
	)

	SelectionManager.selected_entity_freed.connect(
		func():
			clear_markers()
	)

	Messenger.draw_cell_area_requested.connect(draw_cell_area_markers)


func draw_cell_area_markers(cells: Array[Cell]):
	clear_markers()

	for cell in cells:
		var marker = Sprite2D.new()
		add_child(marker)
		marker.texture = _marker_texture
		marker.modulate.a = 0.25
		marker.position = cell.scene_position
		_markers.append(marker)


func clear_markers():
	for marker in _markers:
		marker.queue_free()

	_markers.clear()
