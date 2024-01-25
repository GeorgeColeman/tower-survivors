class_name WeaponEffectChill
extends WeaponEffect

var info: String:
	get:
		var _info = ""

		_info += "Duration %.1f second(s)" % _duration
		_info += "\nChill strength %s%%" % (_factor * 100)

		return _info

var _duration: float = 1.0
#var _chance: float = 1.0
var _factor: float = 0.25


func add_duration(amount: float):
	_duration += amount


#func add_chance(amount: float):
	#_chance += amount


func add_factor(amount: float):
	_factor += amount


func apply_to_mob(mob: Mob):
	#if _chance < randf():
		#return

	var status_effect = StatusEffectFactory.new_slow_status_effect(
		mob,
		_factor,
		_duration)

	mob.status_effects.add_status_effect(status_effect)
