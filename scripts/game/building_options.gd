# --------------------------------------------
# Contains all available building options.
# Also acts as a factory for building options.
# --------------------------------------------

class_name BuildingOptions
extends RefCounted

signal option_added(option: BuildingOption)
signal option_upgraded(option: BuildingOption)

# <PackedScene, BuildingOption>
var _scene_option_dict = {}


func add_building_option(scene: PackedScene, player: Player):
	var unpacked = scene.instantiate()

	if unpacked is Tower:
		var option = BuildingOption.new(
			unpacked.tower_name,
			scene,
			unpacked.main_sprite_2d.texture,
			unpacked.gold_cost
		)

		_scene_option_dict[option.scene] = option

		option.upgraded.connect(
			func(): option_upgraded.emit(option)
		)

		option.update_can_build(player)

		option_added.emit(option)


func get_building_option(scene: PackedScene) -> BuildingOption:
	if _scene_option_dict.has(scene):
		return _scene_option_dict[scene]

	return null


func update_build_options_can_build(player: Player):
	for option in _scene_option_dict.values():
		option.update_can_build(player)
