class_name ControlInGame
extends Control

@export var entity_info_panel: EntityInfoPanel
@export var experience_bar: TextureProgressBar

@onready var gold_text: Label = %GoldText
@onready var time_text: Label = %TimeText

@onready var check_box_game_speed_01: CheckBox = %CheckBoxGameSpeed01
@onready var check_box_game_speed_02: CheckBox = %CheckBoxGameSpeed02
@onready var check_box_game_speed_05: CheckBox = %CheckBoxGameSpeed05
@onready var check_box_game_speed_10: CheckBox = %CheckBoxGameSpeed10

var _game: Game

var _selected_entity
var _entity_is_selected: bool


func _ready():
	Messenger.clicked_on_entity.connect(_on_clicked_on_entity)
	Messenger.clicked_on_empty.connect(_on_clicked_on_empty)

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
	var minutes = (_game.time as int / 60) % 60
	#var hours = (_game.time as int / 60) / 60

	time_text.text = "%02d:%02d" % [minutes, seconds]

	#time_text.text = "%.0f" % _game.time

	# The selected entity has become null, most likely because it's been freed
	if _entity_is_selected && _selected_entity == null:
		_entity_is_selected = false
		entity_info_panel.visible = false


func start_game(game: Game):
	_game = game

	game.player.gold_changed.connect(
		func(current_gold: int):
			_update_gold_text(current_gold)
	)

	game.player.experience_component.experience_added.connect(
		func():
			_update_experience_bar()
	)

	_update_gold_text(game.player.current_gold)
	_update_experience_bar()


func _update_experience_bar():
	experience_bar.value = _game.player.experience_component.perc_to_next_level


func _on_clicked_on_entity(entity):
	_selected_entity = entity
	_entity_is_selected = true

	entity_info_panel.set_entity(entity)
	entity_info_panel.visible = true


func _on_clicked_on_empty():
	entity_info_panel.visible = false


func _update_gold_text(current_gold: int):
	gold_text.text = str(current_gold)


func _set_game_speed(speed: float):
	if !_game:
		return

	_game.speed = speed
