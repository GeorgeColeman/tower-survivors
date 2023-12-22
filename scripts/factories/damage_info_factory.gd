class_name DamageInfoFactory


static func new_damage_info(
	damage_amount: int,
	damage_type: DamageInfo.DamageType = DamageInfo.DamageType.NONE
) -> DamageInfo:
	var damage_info = DamageInfo.new()

	damage_info.damage_amount = damage_amount
	damage_info.damage_type = damage_type

	return damage_info


