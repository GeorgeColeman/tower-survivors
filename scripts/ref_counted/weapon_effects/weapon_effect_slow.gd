class_name WeaponEffectSlow
extends WeaponEffect

var slow_amount: float
var slow_duration: float = 1


func _init(factor: float, duration: float, p_apply_type: Enums.WeaponEffectApplyType):
	slow_amount = factor
	slow_duration = duration
	apply_type = p_apply_type


func apply_to_mob(mob: Mob):
	var status_effect = StatusEffectFactory.new_slow_status_effect(
		mob,
		slow_amount,
		slow_duration)

	mob.status_effects.add_status_effect(status_effect)
