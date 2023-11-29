class_name MapDrawer
extends Node

var cell_scene: PackedScene = preload("res://Scenes/cell.tscn")

var _cell_nodes: Array[Node2D]


func draw_map(map: Map):
	_erase_existing()

	for cell in map.cells:
		var position = map.index_to_coordinates(cell.i)
		var new_cell = cell_scene.instantiate()
		add_child(new_cell)
		new_cell.position = Utilities.get_converted_position(position)
		_cell_nodes.append(new_cell)


func _erase_existing():
	for cell in _cell_nodes:
		cell.queue_free()

	_cell_nodes.clear()
