class_name Player
extends RefCounted

signal gold_changed(current_gold: int)
signal cores_changed(cores: int)
signal levelled_up()

var current_gold: int
var cores: int
var experience_component: ExperienceComponent
var upgrades: Upgrades


func _init(starting_gold: int, starting_cores: int):
	current_gold = starting_gold
	cores = starting_cores

	experience_component = ExperienceComponent.new()
	upgrades = Upgrades.new()

	experience_component.levelled_up.connect(
		func():
			_level_up()
	)

	Messenger.mob_killed.connect(_on_mob_killed)


func add_gold(amount: int):
	if amount == 0:
		return

	current_gold += amount

	gold_changed.emit(current_gold)


func add_cores(amount: int):
	if amount == 0:
		return

	cores += amount

	cores_changed.emit(cores)


func try_buy_core():
	var core_gold_cost = 25				# FIXME: hardcoding

	var has_gold = current_gold >= core_gold_cost

	if !has_gold:
		print_debug("Not enough gold, returning")

		return

	add_gold(-core_gold_cost)
	add_cores(1)


func can_afford_building_option(building_option: BuildingOption) -> bool:
	if GameRules.GOLD_TO_BUILD:
		var has_gold = current_gold >= building_option.gold_cost

		if !has_gold:
			#print_debug("Not enough gold")

			return false

	if GameRules.CORES_TO_BUILD:
		var has_cores = cores >= building_option.tower_resource.core_cost

		if !has_cores:
			#print_debug("Not enough cores")

			return false

	return true


func spend_resources_for_building(building_option: BuildingOption):
	if GameRules.GOLD_TO_BUILD:
		add_gold(-building_option.gold_cost)

	if GameRules.CORES_TO_BUILD:
		add_cores(-building_option.tower_resource.core_cost)


func _on_mob_killed(mob: Mob):
	add_gold(mob.gold_value)

	if GameRules.MOBS_DROP_CORES:
		add_cores(mob.core_value)

	experience_component.add_experience(mob.experience_value)


func _level_up():
	if GameRules.CORE_ON_LEVEL_UP:
		add_cores(1)

	levelled_up.emit()

