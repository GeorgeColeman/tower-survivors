# -----------------------------------------
# Contains all available building optioins.
# -----------------------------------------

class_name BuildingOptions
extends RefCounted

signal option_added(option: BuildingOption)
signal option_upgraded(option: BuildingOption)

# <PackedScene, BuildingOption>
var _scene_option_dict = {}


func add_building_option_packed(scene: PackedScene):
	var unpacked = scene.instantiate()

	if unpacked is Tower:
		_add_building_option(BuildingOption.new(
			scene,
			unpacked.main_sprite_2d.texture,
			unpacked.gold_cost
		))


func _add_building_option(option: BuildingOption):
	_scene_option_dict[option.scene] = option

	option.upgraded.connect(
		func(): option_upgraded.emit(option)
	)

	option_added.emit(option)


func get_building_option(scene: PackedScene) -> BuildingOption:
	if _scene_option_dict.has(scene):
		return _scene_option_dict[scene]

	return null
