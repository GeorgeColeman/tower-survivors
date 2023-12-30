class_name Enums

enum WeaponEffectApplyType {
	ON_HIT
}

enum TargetingType {
	SEEKING,
	LINE
}


static func get_weapon_effect_apply_type(name: String) -> int:
	return WeaponEffectApplyType.get(name)
