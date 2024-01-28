class_name ControlPause
extends Control

@export var continue_button: Button
@export var restart_button: Button
@export var quit_button: Button

@export var sfx_check_box: CheckBox

@export var upgrades_label: Label

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

	sfx_check_box.toggled.connect(func(is_on: bool):
		Audio.toggle_sfx(is_on))


func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE && event.is_released():
			_game.toggle_pause()


func start_game(game: Game):
	_game = game

	_game.run_state_changed.connect(
		func(run_state: Game.RunState):
			match run_state:
				Game.RunState.RUNNING:
					get_tree().paused = false
					_close()
				Game.RunState.PAUSED:
					get_tree().paused = true
					_open()
	)


func _open():
	upgrades_label.text = "Upgrades\n\n%s" % _game.player.upgrades.upgrades_listed

	visible = true


func _close():
	visible = false
