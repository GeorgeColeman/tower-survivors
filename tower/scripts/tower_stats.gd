class_name TowerStats
extends RefCounted

var _weapons: Array[TowerWeapon] = []

var _bonus_damage: int
var _bonus_attack_speed: float
var _bonus_attack_range: int
var _multi_shot: int


func _init(weapons: Array[TowerWeapon]):
	_weapons = weapons


func add_bonus_damage(amount: int):
	_bonus_damage += amount

	for weapon in _weapons:
		weapon.set_bonus_damage(_bonus_damage)


func add_bonus_attack_speed(amount: float):
	_bonus_attack_speed += amount

	for weapon in _weapons:
		weapon.set_bonus_attack_speed(_bonus_attack_speed)


func add_multi_shot(amount: int):
	_multi_shot += amount

	for weapon in _weapons:
		weapon.set_multi_shot(_multi_shot)


func add_bonus_attack_range(amount: int):
	_bonus_attack_range += amount

	for weapon in _weapons:
		weapon.set_bonus_range(_bonus_attack_range)
