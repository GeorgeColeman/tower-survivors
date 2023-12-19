class_name Player
extends RefCounted

signal gold_changed(current_gold: int)
signal levelled_up()
signal upgrade_options_set(options: UpgradeOptions)

var current_gold: int
var experience_component: ExperienceComponent

var _current_upgrade_options: UpgradeOptions


func _init(starting_gold: int):
	current_gold = starting_gold
	experience_component = ExperienceComponent.new()

	experience_component.levelled_up.connect(
		func():
			levelled_up.emit()
	)

	Messenger.mob_killed.connect(_on_mob_killed)


func set_upgrade_options(options: UpgradeOptions):
	_current_upgrade_options = options

	upgrade_options_set.emit(options)


func add_gold(amount: int):
	current_gold += amount
	gold_changed.emit(current_gold)


func _on_mob_killed(mob: Mob):
	add_gold(mob.gold_value)
	experience_component.add_experience(mob.experience_value)
