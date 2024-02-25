# More accurately 'create acid pool'
class_name WeaponEffectAcid
extends WeaponEffect

var info: String:
	get:
		var _info = ""

		_info += "Duration %.1f second(s)" % _duration
		_info += "\nAcid damage %s" % _damage

		return _info

var _duration: float = 1.0
var _damage: int = 1
var _tick_speed: float = 0.5


func add_duration(amount: float):
	_duration += amount


func add_damage(amount: int):
	_damage += amount


func apply_to_hit(hit_info: TowerWeaponHitInfo):
	for cell in hit_info.cells:
		ActiveEffects.create_acid_effect(
			_duration,
			_damage,
			_tick_speed,
			cell
		)
