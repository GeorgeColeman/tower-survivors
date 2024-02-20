class_name MapDrawer
extends Node2D

@export var default_environment: EnvironmentResource

var _cell_nodes: Array[Node2D]


#func _init():
	#Messenger.game_started.connect(
		#func(game: Game):
			#draw_map(game.map)
	#)


func draw_map(map: Map):
	_erase_existing()

	for cell in map.cells:
		var position = map.index_to_coordinates(cell.i)
		var new_cell = Sprite2D.new()
		new_cell.texture = default_environment.primary_cell_type.get_random_texture()
		add_child(new_cell)
		new_cell.position = cell.scene_position
		_cell_nodes.append(new_cell)

		if map.mountains[cell.i]:
			var mountain = Sprite2D.new()
			mountain.texture = default_environment.small_mountain_texture
			mountain.z_index = 1
			add_child(mountain)
			mountain.position = cell.scene_position + Vector2.UP * GameConstants.PIXEL_SCALE * 0.5
			_cell_nodes.append(mountain)

		if map.water[cell.i]:
			var water = Sprite2D.new()
			water.texture = default_environment.primary_water_texture
			water.z_index = 1
			add_child(water)
			water.position = cell.scene_position
			_cell_nodes.append(water)


func _erase_existing():
	for cell in _cell_nodes:
		cell.queue_free()

	_cell_nodes.clear()
