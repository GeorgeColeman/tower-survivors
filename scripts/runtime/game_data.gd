class_name GameData
extends RefCounted

static var tower_weapon_data: Array[TowerWeaponData]
# <string, TowerWeaponData>
static var _tower_weapon_data_dict = {}

var mob_resources: Array[MobResource]
var upgrade_resources: Array[UpgradeResource]
var towers: Array[PackedScene]

var bosses: Array[MobResource]

var _spawnable_mobs: Array[MobResource]

var proto_towers: Array[Tower]


func _init():
	_load_resources()
	tower_weapon_data = _load_tower_weapon_data()

	for data in tower_weapon_data:
		_tower_weapon_data_dict[data.id] = data


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

	var towers = dir_contents("res://scenes/towers/")

	for tower in towers:
		var loaded = load(tower)

		if loaded is PackedScene:
			self.towers.append(loaded)

			var unpacked = loaded.instantiate()

			if unpacked is Tower:
				proto_towers.append(unpacked)

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


func _load_tower_weapon_data() -> Array[TowerWeaponData]:
	var data: Array[TowerWeaponData] = []
	var config = ConfigFile.new()
	var err = config.load("res://config/tower_weapons.cfg")

	if err != OK:
		return []

	for section in config.get_sections():
		var targeting_type = config.get_value(section, "targeting_type")
		var damage = config.get_value(section, "damage")
		var attack_speed = config.get_value(section, "attack_speed")
		var range = config.get_value(section, "range")
		var effects = config.get_value(section, "effects")
		var scene_path = config.get_value(section, "proj_scene_path")
		var sfx_path = config.get_value(section, "sfx")

		#print_debug(targeting_type)

		var sfx: AudioStream

		if sfx_path != "":
			sfx = load(sfx_path)

		var weapon_effects: Array[WeaponEffect] = []

		if effects.has("type"):
			match effects["type"]:
				"burn":
					weapon_effects.append(WeaponEffectBurn.new(
						effects["damage"],
						Enums.get_weapon_effect_apply_type(effects["apply_type"])
					))
				"slow":
					weapon_effects.append(WeaponEffectSlow.new(
						effects["factor"],
						effects["duration"],
						Enums.get_weapon_effect_apply_type(effects["apply_type"])
					))

		data.append(TowerWeaponData.new(
			section,
			Enums.TargetingType.get(targeting_type),
			damage,
			attack_speed,
			range,
			weapon_effects,
			load(scene_path),
			sfx
		))

	return data


static func get_tower_weapon_data(id: String) -> TowerWeaponData:
	if !_tower_weapon_data_dict.has(id):
		print_debug("No tower weapon data with id: ", id)

		return null

	return _tower_weapon_data_dict[id]


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
