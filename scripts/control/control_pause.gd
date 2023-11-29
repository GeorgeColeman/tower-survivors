class_name ControlPause
extends Control

@export var continue_button: Button
@export var restart_button: Button
@export var quit_button: Button

var _game: Game


func _ready():
	continue_button.pressed.connect(func():
		if !_game:
			return
		_game.toggle_pause()
		visible = false)
	restart_button.pressed.connect(func():
		Messenger.start_game_requested.emit())
	quit_button.pressed.connect(func():
		get_tree().quit())


func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE && event.is_released():
			var is_paused = _game.toggle_pause()
			visible = is_paused


func start_game(game: Game):
	_game = game
