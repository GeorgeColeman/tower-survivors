# DEFUNCT

class_name ControlUpgradeOptions
extends Control

@export var upgrade_option_button: PackedScene

@onready var upgrade_options_container = %UpgradeOptionsContainer
@onready var reroll_upgrades_button: Button = %RerollUpgradesButton

var _upgrade_options_buttons: Array[UpgradeOptionButton]


func generate_upgrade_option_buttons(tower: Tower):
	for button in _upgrade_options_buttons:
		button.queue_free()

	_upgrade_options_buttons.clear()

	var upgrades = tower.get_upgrade_options()

	for upgrade in upgrades.options:
		_instantiate_upgrade_button(upgrade, tower)

	# I believe this functions as a pseudo 'remove all listeners'
	for c in reroll_upgrades_button.button_up.get_connections():
		reroll_upgrades_button.button_up.disconnect(c["callable"])

	reroll_upgrades_button.button_up.connect(func():
		tower.clear_upgrade_options()
		generate_upgrade_option_buttons(tower))


func _instantiate_upgrade_button(upgrade: UpgradeResource, tower: Tower):
	var button = upgrade_option_button.instantiate() as UpgradeOptionButton
	upgrade_options_container.add_child(button)
	_upgrade_options_buttons.append(button)
	button.set_description(upgrade.name)
	button.set_on_pressed(func():
		tower.add_upgrade(upgrade)
		self.visible = false)
