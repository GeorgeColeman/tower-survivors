class_name WeaponEffectStasis
extends WeaponEffect

var info: String:
	get:
		var _info = ""

		_info += "Duration %.1f second(s)" % _duration
		_info += "\nChance %s%%" % (_chance * 100)

		return _info

var _duration: float = 1.0
var _chance: float = 0.05


func add_duration(amount: float):
	_duration += amount


func add_chance(amount: float):
	_chance += amount


func apply_to_hit(hit_info: TowerWeaponHitInfo):
	for mob in hit_info.mobs:
		if _chance < randf():
			return

		var status_effect = StatusEffectFactory.new_stasis_status_effect(
			mob,
			_duration)

		mob.status_effects.add_status_effect(status_effect)
