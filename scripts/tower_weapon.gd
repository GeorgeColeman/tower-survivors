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

var rank: int = 1

var _cell: Cell
var _cells_in_range: Array[Cell] = []
var _attack_cooldown: float
var _firing_point: Vector2

var _bonus_damage: int
var _bonus_attack_speed: float
var _bonus_attacks_per_second: float
var _bonus_attack_range: int

var _multi_shot_chance: float
var _multi_shot_number_of_shots: int

var draw_range_indicators = false:
	set(value):
		draw_range_indicators = value
		queue_redraw()

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

	_update_description()


func _draw():
	if not draw_range_indicators:
		return

	draw_arc(Vector2.ZERO, (attack_range + _bonus_attack_range) * 16, 0, TAU, 15, Color.CYAN)

	var color = Color.CYAN
	color.a = 0.5

	var offset := Vector2(global_position.x + 4, global_position.y + 4)

	for cell in _cells_in_range:
		draw_rect(Rect2(cell.position * 16 - offset, Vector2.ONE * 8), color)


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


func rank_up():
	rank += 1

	_update_description()


func _update_description():
	#description = "Rank %s" % rank
	#description += "\nDamage: %s" % (damage + _bonus_damage)
	description = "Damage: %s" % (damage + _bonus_damage)
	description += "\nRange: %s" % (attack_range + _bonus_attack_range)
	description += "\nAttack Speed: %s" % (attacks_per_second + _bonus_attacks_per_second)


func _set_cells_in_range():
	_cells_in_range = GameUtilities.get_cells_in_circle_sorted_by_distance_from(
		_cell, attack_range + _bonus_attack_range)
	queue_redraw()


func _attack():
	# Reset the attack cooldown
	_attack_cooldown = 1 / (attacks_per_second + _bonus_attacks_per_second)

	var multi_shot = _multi_shot_chance >= randf()
	var number_of_shots = 1 + _multi_shot_number_of_shots if multi_shot else 1

	var targets = GameUtilities.get_mob_targets_closest_to_main_tower(_cells_in_range, number_of_shots)
	#var targets = GameUtilities.get_mob_targets(_cells_in_range, number_of_shots)

	for target in targets:
		_spawn_projectile_to_target(target)

	if targets.size() == 0 || !attack_sfx:
		return

	Audio.play_sfx(attack_sfx)


func _spawn_projectile_to_target(target: Mob):
	#match _data.targeting_type:
		#Enums.TargetingType.SEEKING:
			#print_debug("Seeking")
		#Enums.TargetingType.LINE:
			#print_debug("Line")

	var projectile = projectile_scene.instantiate() as Projectile
	add_child(projectile)

	projectile.position = _firing_point
	projectile.set_target(target)
	projectile.set_damage(damage + _bonus_damage)
	projectile.set_range(attack_range + _bonus_attack_range)

	for effect in weapon_effects:
		if effect.apply_type == Enums.WeaponEffectApplyType.ON_HIT:
			projectile.add_on_hit_callback(
				func():
					effect.apply_to_mob(target)
			)


func set_bonus_damage(value: int):
	_bonus_damage = value

	_update_description()


func set_bonus_attack_speed(value: float):
	_bonus_attack_speed = value
	_bonus_attacks_per_second = 1 * _bonus_attack_speed

	_update_description()


func set_multi_shot_chance(value: float):
	_multi_shot_chance = value


func set_multi_shot_number_of_shots(value: int):
	_multi_shot_number_of_shots = value


func set_bonus_range(value: int):
	_bonus_attack_range = value

	# Recalculate cells in range
	_set_cells_in_range()
	_update_description()
