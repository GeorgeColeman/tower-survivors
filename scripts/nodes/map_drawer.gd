class_name MapDrawer
extends Node2D

@export var _default_environment: EnvironmentResource
@export var _map_features_container: Node2D

var _cell_nodes: Array[Node2D]


#func _init():
	#Messenger.game_started.connect(
		#func(game: Game):
			#draw_map(game.map)
	#)


func draw_map(map: Map):
	_erase_existing()

	for cell in map.cells:
		var new_cell = Sprite2D.new()
		new_cell.texture = _default_environment.primary_cell_type.get_random_texture()
		add_child(new_cell)
		new_cell.position = cell.scene_position
		_cell_nodes.append(new_cell)

		var map_feature: Map.MapFeature = map.get_map_feature_at(cell)

		match map_feature:
			Map.MapFeature.SMALL_MOUNTAIN:
				var offset: Vector2 = Vector2.UP * GameConstants.PIXEL_SCALE * 0.5
				_draw_feature(cell, _default_environment.small_mountain_texture, offset)
			Map.MapFeature.BIG_MOUNTAIN:
				var offset: Vector2 = Vector2(GameConstants.PIXEL_SCALE * 0.5, 0)
				_draw_feature(cell, _default_environment.big_mountain_texture, offset)

		if map.water[cell.i]:
			var water = Sprite2D.new()
			water.texture = _default_environment.primary_water_texture
			add_child(water)
			water.position = cell.scene_position
			_cell_nodes.append(water)


func _draw_feature(cell: Cell, texture: Texture2D, offset: Vector2):
	var feature = Sprite2D.new()
	feature.texture = texture
	feature.z_index = 1
	_map_features_container.add_child(feature)
	feature.position = cell.scene_position + offset
	_cell_nodes.append(feature)


func _erase_existing():
	for cell in _cell_nodes:
		cell.queue_free()

	_cell_nodes.clear()
