class_name ControlInGame
extends Control

@onready var tower_health_bar = %TowerHealthBar
@onready var gold_text: Label = %GoldText
@onready var time_text: Label = %TimeText
@onready var control_upgrade_options: ControlUpgradeOptions = %ControlUpgradeOptions

@onready var check_box_game_speed_01: CheckBox = %CheckBoxGameSpeed01
@onready var check_box_game_speed_02: CheckBox = %CheckBoxGameSpeed02
@onready var check_box_game_speed_05: CheckBox = %CheckBoxGameSpeed05
@onready var check_box_game_speed_10: CheckBox = %CheckBoxGameSpeed10

var _game: Game


func _ready():
	Messenger.clicked_on_actor.connect(_on_clicked_on_actor)
	Messenger.clicked_on_empty.connect(_on_clicked_on_empty)

	check_box_game_speed_01.pressed.connect(func(): _set_game_speed(1))
	check_box_game_speed_02.pressed.connect(func(): _set_game_speed(2))
	check_box_game_speed_05.pressed.connect(func(): _set_game_speed(5))
	check_box_game_speed_10.pressed.connect(func(): _set_game_speed(10))

	control_upgrade_options.visible = false


func _process(delta):
	if _game == null:
		return

	time_text.text = "%.0f" % _game.time


#func _input(event):
#	if event is InputEventKey:
#		if event.keycode == KEY_ESCAPE && event.is_released():
#			control_upgrade_options.visible = false


func start_game(game: Game):
	_game = game
	game.tower.hit_points_changed.connect(_on_tower_hit_points_changed)
	game.tower.gold_changed.connect(_on_tower_gold_changed)
	_update_bar_tower_health(game.tower)
	_update_gold_text(game.tower.current_gold)


func _on_clicked_on_actor(actor):
	if actor is Tower:
		if !actor.has_upgrade_points:
			Messenger.request_floating_text("No upgrade points.")
			return

		control_upgrade_options.generate_upgrade_option_buttons(actor)
		control_upgrade_options.visible = true


func _on_clicked_on_empty():
#	control_upgrades.visible = false
	pass


func _on_tower_hit_points_changed(tower: Tower):
	_update_bar_tower_health(tower)


func _on_tower_gold_changed(current_gold: int):
	_update_gold_text(current_gold)


func _update_bar_tower_health(tower: Tower):
	tower_health_bar.value = tower.perc_hit_points * tower_health_bar.max_value


func _update_gold_text(current_gold: int):
	gold_text.text = str(current_gold)


func _set_game_speed(speed: float):
	if !_game:
		return

	_game.speed = speed
