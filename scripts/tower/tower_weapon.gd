# ---------------------------------------------------
# A node that simulates a weapon attached to a tower.
# ---------------------------------------------------

class_name TowerWeapon
extends Node2D

var _data: TowerWeaponData

var id: String
var weapon_name: String
var description: String:
	get:
		return weapon_stats.description

var projectile_scene: PackedScene
#var attack_range: int
#var damage: int
var attack_sfx: AudioStream

var is_active = false
var weapon_effects: Array[WeaponEffect]

var weapon_stats: TowerWeaponStats

var _cell: Cell
var _cells_in_range: Array[Cell] = []
var _attack_cooldown: float
var _firing_point: Vector2
var _projectile_pass: bool					# Does the projectile pass through mobs


func set_data(data: TowerWeaponData):
	_data = data

	id = data.id
	weapon_name = data.name
	weapon_effects = data.weapon_effects
	projectile_scene = data.proj_scene
	#attacks_per_second = data.attack_speed
	#attack_range = data.attack_range
	#damage = data.damage
	attack_sfx = data.sfx

	if data.properties.has("pass"):
		_projectile_pass = data.properties["pass"]

	weapon_stats = TowerWeaponStats.new(
		data.damage,
		data.attack_range,
		data.attack_speed,
		data.projectile_speed
	)
	weapon_stats.attack_range_updated.connect(
		func():
			_set_cells_in_range()
	)


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


func _set_cells_in_range():
	_cells_in_range = GameUtilities.get_cells_in_circle_sorted_by_distance_from(
		_cell,
		weapon_stats.get_total_attack_range()
	)


func _attack():
	# Reset the attack cooldown
	_attack_cooldown = 1 / weapon_stats.attacks_per_second


func _apply_on_hit_weapon_effects(hit_info: TowerWeaponHitInfo):
	for effect in weapon_effects:
		if effect.apply_type == Enums.WeaponEffectApplyType.ON_HIT:
			effect.apply_to_hit(hit_info)
