class_name TowerStats
extends RefCounted

var _weapons: Array[TowerWeapon] = []

var _bonus_damage: int
var _bonus_attack_speed: float
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
		weapon.set_bonus_damage(_bonus_damage)


func add_bonus_attack_speed(amount: float):
	_bonus_attack_speed += amount

	for weapon in _weapons:
		weapon.set_bonus_attack_speed(_bonus_attack_speed)


func add_multi_shot_chance(amount: float):
	_multi_shot_chance += amount

	for weapon in _weapons:
		weapon.set_multi_shot_chance(_multi_shot_chance)


func add_multi_shot(amount: int):
	_multi_shot += amount

	for weapon in _weapons:
		weapon.set_multi_shot_number_of_shots(_multi_shot)


func add_burst_shot(amount: int):
	_burst_shot += amount

	for weapon in _weapons:
		weapon.set_burst_shot_number_of_shots(_burst_shot)


func add_burst_shot_chance(amount: float):
	_burst_shot_chance += amount

	for weapon in _weapons:
		weapon.set_burst_shot_chance(_burst_shot_chance)


func add_bonus_attack_range(amount: int):
	_bonus_attack_range += amount

	for weapon in _weapons:
		weapon.set_bonus_range(_bonus_attack_range)


func add_projectile_speed_mod(amount: float):
	_projectile_speed_mod += amount

	for weapon in _weapons:
		weapon.set_projectile_speed_mod(_projectile_speed_mod)


func add_crit_chance(amount: float):
	_crit_chance += amount

	for weapon in _weapons:
		weapon.set_crit_chance(_crit_chance)
