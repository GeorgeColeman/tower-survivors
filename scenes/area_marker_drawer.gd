extends Node2D

@export var _marker_texture: Texture2D

var _markers: Array[Sprite2D]


func _ready():
	Messenger.clicked_on_entity.connect(
		func(entity_info: EntityInfo):
			print_debug("TEMP: we need a more intelligent way of detecting when a tower is selected")
			if entity_info.entity is Tower:
				draw_cell_area_markers(entity_info.entity._weapons[0]._cells_in_range)
			else:
				clear_markers()
	)

	Messenger.clicked_on_empty.connect(
		func():
			clear_markers()
	)


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
