class_name WeaponEffectBurn
extends WeaponEffect

@export var total_damage: int


func _init(damage: int, apply_type: Enums.WeaponEffectApplyType):
	pass


func apply_to_mob(mob: Mob):
	var status_effect = StatusEffectFactory.new_burn_status_effect(
		mob,
		total_damage
	)

	mob.status_effects.add_status_effect(status_effect)
