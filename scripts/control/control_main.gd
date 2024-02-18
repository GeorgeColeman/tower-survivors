class_name MainControl
extends Control

@export var game_manager: GameManager
@export var start_game_button: Button

@export var control_pre_game: Control
@export var control_in_game: Control
@export var control_game_over: Control
@export var control_pause: Control
@export var control_level_up: ControlLevelUp
@export var control_build_menu: ControlBuildMenu

var _game: Game


func start_game(game: Game):
	_game = game

	control_in_game.start_game(game)
	control_pause.start_game(game)

	control_level_up.reroll_requested.connect(
		func():
			game.upgrades_manager.generate_new_upgrade_options()
	)

	game.game_over.connect(_on_game_over)
	game.player.levelled_up.connect(func(): control_level_up.visible = true)
	game.player.upgrades.upgrade_options_set.connect(
		func(options):
			control_level_up.generate_upgrade_option_buttons(game.player, options)
	)

	control_level_up.dismissed.connect(
		func():
			control_level_up.visible = false
			game.accept_input_and_resume()
	)

	control_pre_game.visible = false
	control_game_over.visible = false
	control_in_game.visible = true
	control_pause.visible = false

	control_build_menu.set_game(game)


func _ready():
	start_game_button.button_down.connect(_on_start_game_button)

	control_pre_game.visible = true
	control_in_game.visible = false
	control_game_over.visible = false


func _on_game_over():
	control_in_game.visible = false
	control_game_over.visible = true


func _on_start_game_button():
	game_manager.start_game()
