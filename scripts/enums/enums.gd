class_name Enums

enum WeaponEffectApplyType {
	ON_HIT
}

enum TargetingType {
	SEEKING,
	LINE,
	AREA,
	MORTAR
}

enum MobFamilyFlags{
	SLIME = 1 << 0,
	HUMANOID = 1 << 1,
	UNDEAD = 1 << 2
}


static func get_weapon_effect_apply_type(name: String) -> int:
	return WeaponEffectApplyType.get(name)
