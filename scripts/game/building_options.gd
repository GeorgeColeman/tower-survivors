# --------------------------------------------
# Contains all available building options.
# Also acts as a factory for building options.
# --------------------------------------------

class_name BuildingOptions
extends RefCounted

signal option_added(option: BuildingOption)
signal option_upgraded(option: BuildingOption)

var _option_dict = {}						# <String, BuildingOption>


func add_building_option(tower_resource: TowerResource, player: Player):
	var option = BuildingOption.new()

	option.tower_resource = tower_resource
	option.is_buildable = !tower_resource.is_main_tower

	_option_dict[tower_resource.name] = option

	option.upgraded.connect(
		func(): 
			option_upgraded.emit(option)
	)

	option.update_can_build(player)

	option_added.emit(option)


func get_building_option(key: String) -> BuildingOption:
	if _option_dict.has(key):
		return _option_dict[key]

	return null


func update_build_options_can_build(player: Player):
	for option in _option_dict.values():
		option.update_can_build(player)
