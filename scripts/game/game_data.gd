class_name GameData
extends RefCounted

static var tower_weapon_data: Array[TowerWeaponData]
static var _tower_weapon_data_dict = {}					# <String, TowerWeaponData>

var mob_resources: Array[MobResource]

var towers: Array[PackedScene]

var bosses: Array[MobResource]
var elites: Array[MobResource]

var spawnable_mobs: Array[MobResource]

var tower_resource_dict = {}							# <String, TowerResource>
var passives_dict = {}									# <String, PassiveUpgrade>
var player_character_dict = {}							# <String, PlayerCharacter>

var mob_camp_resource_dict = {}						# <String, MobCampResource>


func _init():
	DataUtilities.init(self)
	_load_resources()


func _load_resources():
	_load_mobs()
	_load_towers()
	_load_mob_camps()

	var passives = PassiveUpgradeDataResolver.get_passive_upgrade_data()

	for passive in passives:
		passives_dict[passive.id] = passive
		#passives_dict[passive.name] = passive

	var player_characters = PlayerCharacterDataResolver.get_player_characters(self)

	for character in player_characters:
		player_character_dict[character.name] = character

	tower_weapon_data = TowerWeaponDataResolver.get_tower_weapon_data()

	for data in tower_weapon_data:
		_tower_weapon_data_dict[data.id] = data


func _load_mobs():
	var mobs = dir_contents("res://resources/mobs/")

	for mob in mobs:
		var loaded = load(mob)

		if loaded is MobResource:
			mob_resources.append(loaded)

			if loaded.is_in_spawn_pool():
				spawnable_mobs.append(loaded)

			if loaded.is_boss():
				bosses.append(loaded)

			if loaded.is_elite():
				elites.append(loaded)


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


func _load_mob_camps():
	var mob_camp_resources = dir_contents("res://resources/mob_camps/")

	for mob_camp_resource in mob_camp_resources:
		var loaded = load(mob_camp_resource)

		if loaded is MobCampResource:
			mob_camp_resource_dict[loaded.name] = loaded
		else:
			print_debug("WARNING: loaded resource is not MobCampResource")


func get_random_mob_camp_resource() -> MobCampResource:
	return mob_camp_resource_dict.values().pick_random()


func get_tower_weapon_data(id: String) -> TowerWeaponData:
	if !_tower_weapon_data_dict.has(id):
		print_debug("No tower weapon data with id: ", id)

		return null

	return _tower_weapon_data_dict[id]


func try_get_tower_resource(tower_name: String) -> TowerResource:
	if !tower_resource_dict.has(tower_name):
		print_debug("WARNING: no tower with name %s. Returning null" % tower_name)

		return null

	return tower_resource_dict[tower_name]


#func get_random_mob_resource() -> MobResource:
	#return spawnable_mobs[randi_range(0, spawnable_mobs.size() - 1)]


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
