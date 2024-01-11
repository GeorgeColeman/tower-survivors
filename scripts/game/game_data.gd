class_name GameData
extends RefCounted

static var tower_weapon_data: Array[TowerWeaponData]
# <String, TowerWeaponData>
static var _tower_weapon_data_dict = {}

var mob_resources: Array[MobResource]
var upgrade_resources: Array[UpgradeResource]

var towers: Array[PackedScene]

var bosses: Array[MobResource]
var elites: Array[MobResource]

var _spawnable_mobs: Array[MobResource]

var tower_resource_dict = {}					# <String, TowerResource>
var tower_proto_dict = {}						# <String, Tower>

# <String, PassivePerk>
var passives_dict = {}

# <String, PlayerCharacter>
var player_character_dict = {}

func _init():
	_load_resources()
	tower_weapon_data = _load_tower_weapon_data()

	for data in tower_weapon_data:
		_tower_weapon_data_dict[data.id] = data

	_build_prototypes()


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

			if loaded.is_elite():
				elites.append(loaded)

	var upgrades = dir_contents("res://resources/upgrades/")

	for upgrade in upgrades:
		var loaded = load(upgrade)

		if loaded is UpgradeResource:
			upgrade_resources.append(loaded)

	_load_towers()

	var passives = PassivePerkDataResolver.get_passive_perk_data()

	for passive in passives:
		passives_dict[passive.name] = passive

	var player_characters = PlayerCharacterDataResolver.get_player_characters(self)

	for character in player_characters:
		player_character_dict[character.name] = character


func _build_prototypes():
	for key in tower_resource_dict:
		var tower_resource = tower_resource_dict[key]
		var unpacked_tower: Tower = tower_resource.tower_scene.instantiate()

		unpacked_tower.init_weapons()

		tower_proto_dict[key] = unpacked_tower


func _load_towers():
	var tower_resources = dir_contents("res://resources/towers/")

	for tower_resource in tower_resources:
		var loaded = load(tower_resource)

		if loaded is TowerResource:
			tower_resource_dict[loaded.name] = loaded

	var _towers = dir_contents("res://scenes/towers/")

	for tower in _towers:
		var loaded = load(tower)

		if loaded is PackedScene:
			towers.append(loaded)


func _load_tower_weapon_data() -> Array[TowerWeaponData]:
	var data: Array[TowerWeaponData] = []
	var config = ConfigFile.new()
	var err = config.load("res://config/tower_weapons.cfg")

	if err != OK:
		return []

	for section in config.get_sections():
		var name = config.get_value(section, "name")
		var targeting_type = config.get_value(section, "targeting_type")
		var damage = config.get_value(section, "damage")
		var attack_speed = config.get_value(section, "attack_speed")
		var attack_range = config.get_value(section, "range")
		var effects = config.get_value(section, "effects")
		var scene_path = config.get_value(section, "proj_scene_path")
		var sfx_path = config.get_value(section, "sfx")

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
			name,
			Enums.TargetingType.get(targeting_type),
			damage,
			attack_speed,
			attack_range,
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


func try_get_tower_resource(tower_name: String) -> TowerResource:
	if !tower_resource_dict.has(tower_name):
		print_debug("WARNING: no tower with name %s. Returning null" % tower_name)

		return null

	return tower_resource_dict[tower_name]


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
