class_name TowerWeaponStats
extends RefCounted

signal attack_range_updated()

var description: String
var attacks_per_second: float

var _base_damage: int
var _base_attack_range: int
var _base_attack_speed: float
var _base_projectile_speed: float

var _bonus_damage: int
var _bonus_attack_speed: float
var _bonus_attacks_per_second: float
var _attack_speed_mod: float
var _bonus_attack_range: int

var _multi_shot_number_of_shots: int
var _multi_shot_chance: float

var _burst_shot_number_of_shots: int
var _burst_shot_chance: float

var _projectile_speed_mod: float

var _crit_chance: float
var _crit_multiplier: float = 2.0


func _init(
	base_damage: int,
	base_attack_range: int,
	base_attack_speed: float,
	base_projectile_speed: float
):
	_base_damage = base_damage
	_base_attack_range = base_attack_range
	_base_attack_speed = base_attack_speed
	_base_projectile_speed = base_projectile_speed

	_update_final_attacks_per_second()
	_update_description()


func _update_description():
	description = "Damage: %s" % (_base_damage + _bonus_damage)
	description += "\nRange: %s" % (_base_attack_range + _bonus_attack_range)
	description += "\nAttack Speed: %s" % attacks_per_second


func get_multi_shot_number() -> int:
	var multi_shot_proc = _multi_shot_chance >= randf()

	return 1 + _multi_shot_number_of_shots if multi_shot_proc else 1


func get_burst_shot_number() -> int:
	var burst_shot_proc = _burst_shot_chance >= randf()

	return 1 + _burst_shot_number_of_shots if burst_shot_proc else 1


# NOTE: eventually want to pass the target to get more sophisticated calculations - vulnerabilities, etc.
func get_calculated_damage() -> DamageInfo:
	var amount: int = 0
	var is_crit: bool = false

	if _crit_chance >= randf():
		amount = floori((_base_damage + _bonus_damage) * _crit_multiplier)
		is_crit = true
	else:
		amount = _base_damage + _bonus_damage
		is_crit = false

	var damage_info = DamageInfoFactory.new_damage_info(amount)
	damage_info.is_crit = is_crit

	return damage_info


func get_total_attack_range() -> int:
	return _base_attack_range + _bonus_attack_range


func get_total_projectile_speed() -> float:
	return _base_projectile_speed * (1 + _projectile_speed_mod) * GameConstants.PIXEL_SCALE


func add_bonus_damage(value: int):
	_bonus_damage += value

	_update_description()


func add_bonus_attack_speed(value: float):
	_bonus_attack_speed += value
	_bonus_attacks_per_second = 1 * _bonus_attack_speed

	_update_final_attacks_per_second()
	_update_description()


func add_attack_speed_mod(value: float):
	_attack_speed_mod += value

	_update_final_attacks_per_second()
	_update_description()


func add_multi_shot_number_of_shots(value: int):
	_multi_shot_number_of_shots += value


func add_multi_shot_chance(value: float):
	_multi_shot_chance += value


func add_burst_shot_number_of_shots(value: int):
	_burst_shot_number_of_shots += value


func add_burst_shot_chance(value: float):
	_burst_shot_chance += value


func add_bonus_range(value: int):
	_bonus_attack_range += value

	attack_range_updated.emit()
	_update_description()


func add_projectile_speed_mod(value: float):
	_projectile_speed_mod += value


func add_crit_chance(value: float):
	_crit_chance += value


func _update_final_attacks_per_second():
	attacks_per_second = (_base_attack_speed + _bonus_attacks_per_second) * (1 + _attack_speed_mod)
