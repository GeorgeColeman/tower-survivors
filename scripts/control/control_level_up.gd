class_name ControlLevelUp
extends Control

signal dismissed()
signal reroll_requested()

@export var _upgrade_options_container: BoxContainer
@export var _upgrade_option_button: PackedScene
@export var _skip_button: Button
@export var _reroll_button: Button

var _upgrade_options_buttons: Array[UpgradeOptionButton]


func _ready():
	_skip_button.pressed.connect(func(): dismissed.emit())
	_reroll_button.pressed.connect(func(): reroll_requested.emit())


func generate_upgrade_option_buttons(player: Player, upgrade_options: UpgradeOptions):
	for button in _upgrade_options_buttons:
		button.queue_free()

	_upgrade_options_buttons.clear()

	for upgrade in upgrade_options.options:
		_instantiate_upgrade_button(player, upgrade)


func _instantiate_upgrade_button(player: Player, upgrade: UpgradeOption):
	var button = _upgrade_option_button.instantiate() as UpgradeOptionButton
	_upgrade_options_container.add_child(button)
	_upgrade_options_buttons.append(button)
	button.set_upgrade_option(upgrade)
	button.pressed.connect(
		func():
			player.upgrades.add_upgrade(upgrade)
			dismissed.emit()
	)
