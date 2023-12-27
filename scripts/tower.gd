class_name Tower
extends Node2D

signal was_killed()

@export var hit_points_component: HitPointsComponent

@export var id: int
@export var tower_name: String
@export var main_sprite_2d: Sprite2D
@export var weapon_ids: Array[String] = []
@export var max_hit_points := 50 as int
@export var gold_cost: int = 20
@export var animation_player: AnimationPlayer
@export var firing_point: Marker2D
@export_flags("IS_MAIN_TOWER") var _flags = 0

var draw_range_indicators = false:
	set(value):
		draw_range_indicators = value

		for weapon in _weapons:
			weapon.draw_range_indicators = value

var kills: int
var cell: Cell
var tower_stats: TowerStats

var _weapons: Array[TowerWeapon] = []
var _is_destroyed: bool
var _rank: int = 1

var description: String:
	get:
		var d = "Rank %s" % _rank

		if _weapons.size() > 0:
			d += str("\n", _weapons[0].stats_description)

		return d

var weapons_description: String:
	get:
		var s = ""

		for weapon in _weapons:
			s += str(weapon.stats_description, "\n")

		return s.substr(0, s.length() - 1)

var is_possible_new_tower_upgrade_perk: bool:
	get:
		return !_has_flag(TowerFlags.IS_MAIN_TOWER)


func _ready():
#	main_sprite_2d.offset = GameUtilities.calculate_sprite_offset(main_sprite_2d)
	pass


func uninstantiate():
	# Kill tweens (if any)
	queue_free()


func init_weapons():
	for weapon in weapon_ids:
		var weapon_data: TowerWeaponData = GameData.get_tower_weapon_data(weapon)

		if !weapon_data:
			return

		var weapon_node = TowerWeapon.new()
		weapon_node.set_data(weapon_data)

		_attach_weapon(weapon_node)


func set_cell_and_init(p_cell: Cell):
	cell = p_cell

	hit_points_component.initialise(max_hit_points, true)
	tower_stats = TowerStats.new(_weapons)

	for weapon in _weapons:
		weapon.set_cell(p_cell)


func set_rank(value: int):
	_rank = value


func add_rank(amount: int):
	_rank += amount


func _attach_weapon(weapon: TowerWeapon):
	add_child(weapon)
	weapon.is_active = true

	if cell:
		weapon.set_cell(cell)

	weapon.set_firing_point(firing_point.position)
	_weapons.append(weapon)


func take_damage(amount: int):
	hit_points_component.change_current(-amount)

	if hit_points_component.is_at_zero:
		_destroy()

	TweenEffects.flash_white(main_sprite_2d, Color.WHITE)


func _destroy():
	_is_destroyed = true
	was_killed.emit()

	animation_player.play("destroy")

	# Deactivate weapons
	for weapon in _weapons:
		weapon.is_active = false


func _has_flag(flag: TowerFlags):
	return _flags & flag != 0


enum TowerFlags {
	IS_MAIN_TOWER = 1 << 0
}
