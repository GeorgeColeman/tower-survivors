class_name WeaponEffectStasis
extends WeaponEffect

var _duration: float = 1.0
var _chance: float


func add_duration(amount: float):
	_duration += amount


func add_chance(amount: float):
	_chance += amount


func apply_to_mob(mob: Mob):
	if _chance < randf():
		return

	var status_effect = StatusEffectFactory.new_stasis_status_effect(
		mob,
		_duration)

	mob.status_effects.add_status_effect(status_effect)
