class_name StatusEffectFactory


static func new_slow_status_effect(
	mob: Mob,
	slow_amount: float,
	slow_duration: float
	) -> StatusEffect:
	var status_effect = StatusEffect.new()

	status_effect.name = "slow"
	status_effect.duration = slow_duration

	status_effect.add = func():
		mob.add_move_speed_modifier(-slow_amount)
		mob.set_tint_colour(Color.AQUA * 1.5)
	status_effect.remove = func():
		mob.add_move_speed_modifier(slow_amount)
		mob.set_tint_colour(Color.WHITE)

#	status_effect.add = func(mob: Mob):
#		mob.add_move_speed_modifier(-slow_amount)
#		mob.set_tint_colour(Color.AQUA * 1.5)
#	status_effect.remove = func(mob: Mob):
#		mob.add_move_speed_modifier(slow_amount)
#		mob.set_tint_colour(Color.WHITE)

	return status_effect
