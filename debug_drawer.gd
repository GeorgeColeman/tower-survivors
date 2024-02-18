extends Node2D

@export var font: Font
@export var _mob_spawner: MobSpawner

var _test_string = "TEST"
var _game: Game


func _init():
	Messenger.game_started.connect(_on_game_started)


func _process(delta):
	queue_redraw()


func _on_game_started(game: Game):
	_game = game
	_test_string = "GAME STARTED"

	#queue_redraw()


func _draw():
	if !_game:
		return

	var offset: Vector2 = Vector2.ZERO
	#var offset: Vector2 = -Vector2.ONE * 0.5 * GameConstants.PIXEL_SCALE

	for y in _game.map.height:
		for x in _game.map.width:
			var str: String = str(_mob_spawner.get_mobs_at(_game.map.get_cell_at(x, y)).size())
			draw_multiline_string(font, _game.map.get_cell_at(x, y).scene_position + offset, str)


