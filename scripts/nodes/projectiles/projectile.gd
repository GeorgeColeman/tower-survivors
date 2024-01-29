class_name Projectile
extends Node2D

var _speed: float
var _does_pass: bool
var _effects: Array[WeaponEffect]


func set_target(_target_mob: Mob):
	pass


func set_weapon_effects(weapon_effects: Array[WeaponEffect]):
	_effects = weapon_effects


func apply_weapon_effects_to_hit(hit_info: TowerWeaponHitInfo):
	for effect in _effects:
		effect.apply_to_hit(hit_info);


func set_damage(_value: int):
	pass


func set_range(_value: int):
	pass


func set_speed(speed: float):
	_speed = speed


func set_pass(does_pass: bool):
	_does_pass = does_pass
