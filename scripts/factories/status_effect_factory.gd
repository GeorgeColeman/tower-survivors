class_name StatusEffectFactory

const _burn_duration: float = 3.0
const _burn_tick: float = 1.0


static func new_burn_status_effect(
	mob: Mob,
	total_damage: int
) -> StatusEffect:
	var status_effect = StatusEffect.new()

	status_effect.name = "burn"
	# Additional duration to ensure all burn ticks are applied
	status_effect.duration = _burn_duration + _burn_tick * 0.25
	status_effect.properties["burn_timer"] = 0

	var burn_damage_per_tick: int = floori(total_damage / _burn_duration)

	status_effect.update = func(delta: float):
		status_effect.properties["burn_timer"] += delta

		if status_effect.properties["burn_timer"] >= _burn_tick:
			mob.take_damage(
				DamageInfoFactory.new_damage_info(burn_damage_per_tick, DamageInfo.DamageType.FIRE)
			)
			status_effect.properties["burn_timer"] = 0

	return status_effect


static func new_slow_status_effect(
	mob: Mob,
	slow_amount: float,
	slow_duration: float
) -> StatusEffect:
	var status_effect = StatusEffect.new()

	status_effect.name = "slow"
	status_effect.duration = slow_duration

	status_effect.add = func():
		mob.movement.add_move_speed_modifier(-slow_amount)
		mob.set_tint_colour(Color.AQUA * 1.5)
	status_effect.remove = func():
		mob.movement.add_move_speed_modifier(slow_amount)
		mob.set_tint_colour(Color.WHITE)

	return status_effect


static func new_stasis_status_effect(
	mob: Mob,
	stasis_duration: float
) -> StatusEffect:
	var status_effect = StatusEffect.new()

	status_effect.name = "stasis"
	status_effect.duration = stasis_duration

	status_effect.add = func():
		mob.movement.set_is_mobile(false)
		mob.set_tint_colour(Color.INDIGO * 1.5)
	status_effect.remove = func():
		mob.movement.set_is_mobile(true)			# NOTE: frail implementation. Will not work if immobilisation is applied from another source
		mob.set_tint_colour(Color.WHITE)

	return status_effect
