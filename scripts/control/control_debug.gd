class_name ControlDebug
extends Control

@export var check_box_draw_range_indicators: CheckBox
@export var check_box_draw_pathfinding_grid: CheckBox
@export var check_box_draw_mob_paths: CheckBox
@export var check_box_show_damage_numbers: CheckBox

@onready var game_events_text = %GameEventsText
@onready var restart_game_button = %RestartGameButton
@onready var damage_tower_button = %DamageTowerButton
@onready var kill_tower_button = %KillTowerButton

@export_group("Buttons")
@export var spawn_boss_button: Button
@export var level_up_button: Button
@export var add_gold_button: Button

var _game_manager: GameManager
var _game: Game


func _ready():
	Messenger.game_event_occured.connect(_on_game_event_occured)
	game_events_text.text = ""
	restart_game_button.pressed.connect(func(): Messenger.start_game_requested.emit())
	damage_tower_button.pressed.connect(func():
		if !_game:
			return

		_game.tower.take_damage(5))

	kill_tower_button.pressed.connect(func():
		if !_game:
			return

		_game.tower.take_damage(999))

	check_box_draw_range_indicators.toggled.connect(_on_toggle_draw_range_indicators)
	check_box_draw_pathfinding_grid.toggled.connect(_on_toggle_draw_pathfinding_grid)
	check_box_draw_mob_paths.toggled.connect(_on_toggle_draw_mob_paths)
	check_box_show_damage_numbers.toggled.connect(_on_toggle_show_damage_numbers)

	spawn_boss_button.pressed.connect(
		func():
			if !_game:
				return

			_game.mob_spawner.spawn_random_boss()
	)

	level_up_button.pressed.connect(
		func():
			if !_game: return

			_game.player.experience_component.DEBUG_manual_level_up()
	)

	add_gold_button.pressed.connect(
		func():
			if !_game: return

			_game.player.add_gold(100)
	)

	visible = false


func _input(event):
	if event is InputEventKey:
		if event.is_released() && event.keycode == KEY_TAB:
			visible = !visible


func set_game_manager(game_manager: GameManager):
	_game_manager = game_manager


func start_game(game: Game):
	_game = game
	game_events_text.text = ""
	_add_game_event_line("Game started.")


func _add_game_event_line(message: String):
	if game_events_text.text == "":
		game_events_text.text = message

		return

	game_events_text.text = str(game_events_text.text, "\n", message)


func _on_game_event_occured(game_event: GameEvent):
	_add_game_event_line(game_event.message)


func _on_toggle_draw_range_indicators(button_pressed: bool):
	_game.tower.draw_range_indicators = button_pressed


func _on_toggle_draw_pathfinding_grid(button_pressed: bool):
	_game_manager.pathfinding_manager.draw_pathfinding_grid = button_pressed


func _on_toggle_draw_mob_paths(button_pressed: bool):
	_game_manager.pathfinding_manager.draw_mob_paths = button_pressed


func _on_toggle_show_damage_numbers(button_pressed: bool):
	_game_manager.special_effects.show_damage_text = button_pressed
