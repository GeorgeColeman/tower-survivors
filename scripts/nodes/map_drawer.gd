class_name MapDrawer
extends Node2D

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

		if map.mountains[cell.i]:
			var mountain = Sprite2D.new()
			mountain.texture = load("res://sprites/map/mountain.tres")
			mountain.z_index = 1
			add_child(mountain)
			mountain.position = cell.scene_position
			_cell_nodes.append(mountain)

		if map.water[cell.i]:
			var water = Sprite2D.new()
			water.texture = load("res://sprites/map/water.tres")
			water.z_index = 1
			add_child(water)
			water.position = cell.scene_position
			_cell_nodes.append(water)


func _erase_existing():
	for cell in _cell_nodes:
		cell.queue_free()

	_cell_nodes.clear()
