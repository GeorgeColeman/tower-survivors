class_name BuildingOptions
extends RefCounted

signal option_added(scene: PackedScene)

var _options: Array[PackedScene] = []


func add_building_option(scene: PackedScene):
	_options.append(scene)

	option_added.emit(scene)
