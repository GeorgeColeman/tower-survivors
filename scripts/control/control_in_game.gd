class_name ControlInGame
extends Control

@export var entity_info_panel: EntityInfoPanel

@export var level_label: Label
@export var experience_bar: TextureProgressBar

@export var gold_label: Label
@export var time_label: Label
@export var cores_label: Label

@export var buy_core_button: Button

@export_group("Game Speed Controls")
@export var check_box_game_speed_01: CheckBox
@export var check_box_game_speed_02: CheckBox
@export var check_box_game_speed_05: CheckBox
@export var check_box_game_speed_10: CheckBox

var _game: Game


func _ready():
	SelectionManager.entity_selected.connect(
		func(entity_info: EntityInfo):
			entity_info_panel.open()
			entity_info_panel.set_entity(entity_info)
	)

	SelectionManager.selection_cleared.connect(
		func():
			entity_info_panel.close()
			entity_info_panel.clear_entity()
	)

	SelectionManager.selected_entity_freed.connect(
		func():
			entity_info_panel.close()
			entity_info_panel.clear_entity()
	)

	buy_core_button.pressed.connect(_on_buy_core_button_pressed)

	check_box_game_speed_01.pressed.connect(func(): _set_game_speed(1))
	check_box_game_speed_02.pressed.connect(func(): _set_game_speed(2))
	check_box_game_speed_05.pressed.connect(func(): _set_game_speed(5))
	check_box_game_speed_10.pressed.connect(func(): _set_game_speed(10))

	entity_info_panel.visible = false


func _process(_delta):
	if _game == null:
		return

	# Source: https://forum.godotengine.org/t/how-to-convert-seconds-into-ddmm-ss-format/8174/2
	var seconds = _game.time as int % 60
	var minutes = (_game.time / 60) as int % 60
	#var hours = (_game.time as int / 60) / 60

	time_label.text = "%02d:%02d" % [minutes, seconds]

	#time_text.text = "%.0f" % _game.time


func start_game(game: Game):
	_game = game

	game.player.gold_changed.connect(
		func(current_gold: int):
			_update_gold_text(current_gold)
	)

	game.player.cores_changed.connect(
		func(cores: int):
			_update_cores_text(cores)
	)

	game.player.experience_component.experience_added.connect(
		func():
			_update_experience_bar()
	)

	_update_gold_text(game.player.current_gold)
	_update_cores_text(game.player.cores)
	_update_experience_bar()


func _update_experience_bar():
	level_label.text = "Level %02d" % _game.player.experience_component.level
	experience_bar.value = _game.player.experience_component.perc_to_next_level


func _on_buy_core_button_pressed():
	_game.player.try_buy_core()


func _update_gold_text(current_gold: int):
	gold_label.text = str(current_gold)


func _update_cores_text(cores: int):
	cores_label.text = str(cores)


func _set_game_speed(speed: float):
	if !_game:
		return

	_game.set_speed(speed)
