class_name ControlLevelUp
extends Control

signal dismissed()
signal reroll_requested()

@export var upgrade_options_container: BoxContainer
@export var upgrade_option_button: PackedScene
@export var dismiss_button: Button
@export var _reroll_button: Button

var _upgrade_options_buttons: Array[UpgradeOptionButton]


func _ready():
	dismiss_button.pressed.connect(func(): dismissed.emit())
	_reroll_button.pressed.connect(func(): reroll_requested.emit())


func generate_upgrade_option_buttons(player: Player, upgrade_options: UpgradeOptions):
	for button in _upgrade_options_buttons:
		button.queue_free()

	_upgrade_options_buttons.clear()

	for upgrade in upgrade_options.options:
		_instantiate_upgrade_button(player, upgrade)


func _instantiate_upgrade_button(player: Player, upgrade: UpgradeOption):
	var button = upgrade_option_button.instantiate() as UpgradeOptionButton
	upgrade_options_container.add_child(button)
	_upgrade_options_buttons.append(button)
	button.set_upgrade_option(upgrade)
	button.pressed.connect(
		func():
			player.upgrades.add_upgrade(upgrade)
			#upgrade.apply()
			dismissed.emit()
	)
