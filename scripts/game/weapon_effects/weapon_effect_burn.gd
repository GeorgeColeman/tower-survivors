class_name WeaponEffectBurn
extends WeaponEffect

var total_damage: int


func _init(damage: int, p_apply_type: Enums.WeaponEffectApplyType):
	total_damage = damage
	apply_type = p_apply_type


func apply_to_hit(hit_info: TowerWeaponHitInfo):
	for mob in hit_info.mobs:
		var status_effect = StatusEffectFactory.new_burn_status_effect(
			mob,
			total_damage
		)

		mob.status_effects.add_status_effect(status_effect)
