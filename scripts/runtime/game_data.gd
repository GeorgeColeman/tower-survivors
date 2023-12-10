class_name GameData
extends RefCounted

var mob_resources: Array[MobResource]
var upgrade_resources: Array[UpgradeResource]

var bosses: Array[MobResource]

var _spawnable_mobs: Array[MobResource]


func _init():
	_load_resources()


func _load_resources():
	var mobs = dir_contents("res://resources/mobs/")

	for mob in mobs:
		var loaded = load(mob)

		if loaded is MobResource:
			mob_resources.append(loaded)

			if loaded.is_in_spawn_pool():
				_spawnable_mobs.append(loaded)

			if loaded.is_boss():
				bosses.append(loaded)

	var upgrades = dir_contents("res://resources/upgrades/")

	for upgrade in upgrades:
		var loaded = load(upgrade)

		if loaded is UpgradeResource:
			upgrade_resources.append(loaded)

#	var path = "res://resources"
#	var dir = DirAccess.open(path)
#	var files = dir.get_files()
#	for file in files:
#		var loaded = load(str(path, "/", file))
#
#		print(loaded)
#
#		if loaded is MobResource:
#			mob_resources.append(loaded)
#
#		if loaded is UpgradeResource:
#			upgrade_resources.append(loaded)


func get_random_mob_resource() -> MobResource:
	return _spawnable_mobs[randi_range(0, _spawnable_mobs.size() - 1)]


func dir_contents(path) -> Array:
	var files = []

	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				files.append(path + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

	return files
