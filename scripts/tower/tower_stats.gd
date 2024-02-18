# NOTE: this does not need to be individualised for each tower.
# Its more 'shared stats' as a result from passive upgrades
class_name TowerStats
extends RefCounted

var _weapons: Array[TowerWeapon] = []

var _bonus_damage: int
var _bonus_attack_speed: float
var _attack_speed_mod: float
var _bonus_attack_range: int

var _multi_shot: int
var _multi_shot_chance: float

var _burst_shot: int
var _burst_shot_chance: float

var _projectile_speed_mod: float

var _weapon_effect_dict = {}

var _crit_chance: float


func _init(weapons: Array[TowerWeapon]):
	_weapons = weapons


func add_weapon_effect(name: String, weapon_effect: WeaponEffect):
	_weapon_effect_dict[name] = weapon_effect

	for weapon in _weapons:
		weapon.add_weapon_effect(weapon_effect)


func try_get_weapon_effect(name: String) -> WeaponEffect:
	if _weapon_effect_dict.has(name):
		return _weapon_effect_dict[name]

	return null


func add_bonus_damage(amount: int):
	_bonus_damage += amount

	for weapon in _weapons:
		weapon.weapon_stats.add_bonus_damage(amount)


func add_bonus_attack_speed(amount: float):
	_bonus_attack_speed += amount

	for weapon in _weapons:
		weapon.weapon_stats.add_bonus_attack_speed(amount)


func add_attack_speed_mod(amount: float):
	_attack_speed_mod += amount

	for weapon in _weapons:
		weapon.weapon_stats.add_attack_speed_mod(amount)


func add_multi_shot_chance(amount: float):
	_multi_shot_chance += amount

	for weapon in _weapons:
		weapon.weapon_stats.add_multi_shot_chance(amount)


func add_multi_shot(amount: int):
	_multi_shot += amount

	for weapon in _weapons:
		weapon.weapon_stats.add_multi_shot_number_of_shots(amount)


func add_burst_shot(amount: int):
	_burst_shot += amount

	for weapon in _weapons:
		weapon.weapon_stats.add_burst_shot_number_of_shots(amount)


func add_burst_shot_chance(amount: float):
	_burst_shot_chance += amount

	for weapon in _weapons:
		weapon.weapon_stats.add_burst_shot_chance(amount)


func add_bonus_attack_range(amount: int):
	_bonus_attack_range += amount

	for weapon in _weapons:
		weapon.weapon_stats.add_bonus_range(amount)


func add_projectile_speed_mod(amount: float):
	_projectile_speed_mod += amount

	for weapon in _weapons:
		weapon.weapon_stats.set_projectile_speed_mod(amount)


func add_crit_chance(amount: float):
	_crit_chance += amount

	for weapon in _weapons:
		weapon.weapon_stats.set_crit_chance(amount)
