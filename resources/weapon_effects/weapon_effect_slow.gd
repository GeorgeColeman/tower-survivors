class_name WeaponEffectSlow
extends WeaponEffect

@export_range(0, 1) var slow_amount: float
@export var slow_duration: float = 1

func apply_to_mob(mob: Mob):
	var status_effect = StatusEffectFactory.new_slow_status_effect(
		mob,
		slow_amount,
		slow_duration)

	mob.status_effects.add_status_effect(status_effect)
