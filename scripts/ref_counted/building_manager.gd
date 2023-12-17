class_name BuildingManager
extends RefCounted

var _entity_drawer: EntityDrawer
var _building_options: BuildingOptions


func set_building_options(building_options: BuildingOptions):
	_building_options = building_options

	building_options.option_upgraded.connect(
		func():
			pass			# TODO
	)
