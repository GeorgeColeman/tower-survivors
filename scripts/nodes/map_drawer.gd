class_name MapDrawer
extends Node

@export var cell_type: CellTypeResource

var _cell_nodes: Array[Node2D]


func draw_map(map: Map):
	_erase_existing()

	for cell in map.cells:
		var position = map.index_to_coordinates(cell.i)
		var new_cell = Sprite2D.new()
		new_cell.texture = cell_type.get_random_texture()
		add_child(new_cell)
		new_cell.position = cell.scene_position
		_cell_nodes.append(new_cell)


func _erase_existing():
	for cell in _cell_nodes:
		cell.queue_free()

	_cell_nodes.clear()
