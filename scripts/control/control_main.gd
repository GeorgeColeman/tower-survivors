class_name MainControl
extends Control

@export var game_manager: GameManager
@export var start_game_button: Button

@export var control_pre_game: Control
@export var control_in_game: Control
@export var control_game_over: Control
@export var control_pause: Control

var _game: Game


func start_game(game: Game):
	_game = game
	game.game_over.connect(_on_game_over)

	control_pre_game.visible = false
	control_game_over.visible = false
	control_in_game.visible = true
	control_pause.visible = false


func _ready():
	start_game_button.button_down.connect(_on_start_game_button)

	control_pre_game.visible = true
	control_in_game.visible = false
	control_game_over.visible = false


#func _input(event):
#	if event is InputEventKey:
#		if event.keycode == KEY_ESCAPE && event.is_released():
#			var is_paused = _game.toggle_pause()
#			control_pause.visible = is_paused


func _on_game_over():
	control_in_game.visible = false
	control_game_over.visible = true


func _on_start_game_button():
	game_manager.start_game()
