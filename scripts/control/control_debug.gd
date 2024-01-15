class_name ControlDebug
extends Control

@export var check_box_draw_pathfinding_grid: CheckBox
@export var check_box_draw_mob_paths: CheckBox
@export var check_box_show_damage_numbers: CheckBox

@export var game_events_text: Label

@export_group("Buttons")
@export var restart_game_button: Button
@export var damage_tower_button: Button
@export var kill_tower_button: Button
@export var spawn_boss_button: Button
@export var level_up_button: Button
@export var add_gold_button: Button
@export var spawn_new_spawn_point_button: Button

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

	spawn_new_spawn_point_button.pressed.connect(
		func():
			if !_game_manager: return

			_game_manager.mob_spawner.spawn_new_spawn_point()
	)

	visible = false


#func _dict_vs_instance_test():
	#var iterations: int = 1_000_000
#
	#var dict_runtime = Utilities.get_function_runtime(
		#func():
			#for i in iterations:
				#var damage_info_dict = {}
				#damage_info_dict["damage_type"] = "fire"
				#damage_info_dict["damage_amount"] = 4
				#var damage_type = damage_info_dict["damage_type"]
				#var damage_amount = damage_info_dict["damage_amount"]
	#)
#
	#print_debug("Dictionaries in: ", dict_runtime)
#
	#var instance_runtime = Utilities.get_function_runtime(
		#func():
			#for i in iterations:
				#var damage_info = DamageInfo.new()
				#damage_info.damage_type = "fire"
				#damage_info.damage_amount = 4
				#var damage_type = damage_info.damage_type
				#var damage_amount = damage_info.damage_amount
	#)
#
	#print_debug("Instances in: ", instance_runtime)
	#
	#var damage_info = DamageInfo.new()
	#
	#var cached_instance_runtime = Utilities.get_function_runtime(
		#func():
			#for i in iterations:
				#damage_info.damage_type = "fire"
				#damage_info.damage_amount = 4
				#var damage_type = damage_info.damage_type
				#var damage_amount = damage_info.damage_amount
	#)
#
	#print_debug("Cached instances in: ", cached_instance_runtime)


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


func _on_toggle_draw_pathfinding_grid(button_pressed: bool):
	_game_manager.pathfinding_manager.draw_pathfinding_grid = button_pressed


func _on_toggle_draw_mob_paths(button_pressed: bool):
	_game_manager.pathfinding_manager.draw_mob_paths = button_pressed


func _on_toggle_show_damage_numbers(button_pressed: bool):
	_game_manager.vfx_drawer_2d.show_damage_text = button_pressed
