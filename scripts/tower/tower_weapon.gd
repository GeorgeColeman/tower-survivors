# ---------------------------------------------------
# A node that simulates a weapon attached to a tower.
# ---------------------------------------------------

class_name TowerWeapon
extends Node2D

var _data: TowerWeaponData

var id: String
var weapon_name: String

var projectile_scene: PackedScene
var attacks_per_second: float
var attack_range: int
var damage: int
var attack_sfx: AudioStream

var is_active = false
var weapon_effects: Array[WeaponEffect]

var _cell: Cell
var _cells_in_range: Array[Cell] = []
var _attack_cooldown: float
var _firing_point: Vector2

var _bonus_damage: int
var _bonus_attack_speed: float
var _bonus_attacks_per_second: float
var _bonus_attack_range: int

var _multi_shot_number_of_shots: int
var _multi_shot_chance: float

var _burst_shot_number_of_shots: int
var _burst_shot_chance: float

var _projectile_speed_mod: float
var _projectile_pass: bool					# Does the projectile pass through mobs

var description: String


func set_data(data: TowerWeaponData):
	_data = data

	id = data.id
	weapon_name = data.name
	weapon_effects = data.weapon_effects
	projectile_scene = data.proj_scene
	attacks_per_second = data.attack_speed
	attack_range = data.attack_range
	damage = data.damage
	attack_sfx = data.sfx

	if data.properties.has("pass"):
		_projectile_pass = data.properties["pass"]

	_update_description()


func _process(_delta: float):
	if not is_active:
		return

	_attack_cooldown -= Game.speed_scaled_delta

	if _attack_cooldown <= 0:
		_attack()


func set_cell(cell: Cell):
	_cell = cell
	_set_cells_in_range()


func set_firing_point(point: Vector2):
	_firing_point = point


func add_weapon_effect(weapon_effect: WeaponEffect):
	weapon_effects.append(weapon_effect)


func _update_description():
	#description = "Rank %s" % rank
	#description += "\nDamage: %s" % (damage + _bonus_damage)
	description = "Damage: %s" % (damage + _bonus_damage)
	description += "\nRange: %s" % (attack_range + _bonus_attack_range)
	description += "\nAttack Speed: %s" % (attacks_per_second + _bonus_attacks_per_second)


func _set_cells_in_range():
	_cells_in_range = GameUtilities.get_cells_in_circle_sorted_by_distance_from(
		_cell, attack_range + _bonus_attack_range)


func _attack():
	# Reset the attack cooldown
	_attack_cooldown = 1 / (attacks_per_second + _bonus_attacks_per_second)


func _apply_on_hit_weapon_effects(hit_info: TowerWeaponHitInfo):
	for effect in weapon_effects:
		if effect.apply_type == Enums.WeaponEffectApplyType.ON_HIT:
			effect.apply_to_hit(hit_info)


func set_bonus_damage(value: int):
	_bonus_damage = value

	_update_description()


func set_bonus_attack_speed(value: float):
	_bonus_attack_speed = value
	_bonus_attacks_per_second = 1 * _bonus_attack_speed

	_update_description()


func set_multi_shot_number_of_shots(value: int):
	_multi_shot_number_of_shots = value


func set_multi_shot_chance(value: float):
	_multi_shot_chance = value


func set_burst_shot_number_of_shots(value: int):
	_burst_shot_number_of_shots = value


func set_burst_shot_chance(value: float):
	_burst_shot_chance = value


func set_bonus_range(value: int):
	_bonus_attack_range = value

	# Recalculate cells in range
	_set_cells_in_range()
	_update_description()


func set_projectile_speed_mod(value: float):
	_projectile_speed_mod = value
