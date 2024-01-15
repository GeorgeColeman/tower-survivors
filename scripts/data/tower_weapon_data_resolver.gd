class_name TowerWeaponDataResolver
extends RefCounted

static func get_tower_weapon_data() -> Array[TowerWeaponData]:
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
		var projectile_speed = config.get_value(section, "projectile_speed")
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
			projectile_speed,
			weapon_effects,
			load(scene_path),
			sfx
		))

	return data
