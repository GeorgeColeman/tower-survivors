class_name ControlLevelUp
extends Control

signal dismissed()

@export var upgrade_options_container: BoxContainer
@export var upgrade_option_button: PackedScene
@export var dismiss_button: Button
@export var _reroll_button: Button

var _upgrade_options_buttons: Array[UpgradeOptionButton]


func _ready():
	dismiss_button.pressed.connect(func(): dismissed.emit())
	_reroll_button.pressed.connect(func(): _reroll_options())


# TODO: in future we don't want to actually generate the upgrade options in this class
# IDEA: the upgrade options themselves could contain the functionality to reroll themselves
func generate_upgrade_options():
	generate_upgrade_option_buttons(GameUtilities.generate_upgrade_options(3))


func generate_upgrade_option_buttons(upgrade_options: UpgradeOptions):
	for button in _upgrade_options_buttons:
		button.queue_free()

	_upgrade_options_buttons.clear()

	for upgrade in upgrade_options.options:
		_instantiate_upgrade_button(upgrade)


func _instantiate_upgrade_button(upgrade: UpgradeOption):
	var button = upgrade_option_button.instantiate() as UpgradeOptionButton
	upgrade_options_container.add_child(button)
	_upgrade_options_buttons.append(button)
	button.set_description(upgrade.name)
	button.pressed.connect(
		func():
			upgrade.apply()
			dismissed.emit()
	)


func _reroll_options():
	generate_upgrade_options()
