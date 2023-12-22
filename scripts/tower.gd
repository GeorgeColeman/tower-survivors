class_name Tower
extends Node2D

signal was_killed()

@export var hit_points_component: HitPointsComponent

@export var id: int
@export var tower_name: String
@export var main_sprite_2d: Sprite2D
@export var starting_weapons: Array[PackedScene]
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

		# TODO: fix this hack. We are instantiating the tower's weapons
		# every time we need information about them.
		for weapon in starting_weapons:
			var new_weapon = weapon.instantiate() as TowerWeapon
			s += str(new_weapon.stats_description, "\n")

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


func set_cell_and_init(p_cell: Cell):
	cell = p_cell

	hit_points_component.initialise(max_hit_points, true)
	tower_stats = TowerStats.new(_weapons)

	for weapon in starting_weapons:
		var new_weapon = weapon.instantiate() as TowerWeapon
		_attach_weapon(new_weapon)


func set_rank(value: int):
	_rank = value


func add_rank(amount: int):
	_rank += amount


func _attach_weapon(weapon: TowerWeapon):
	add_child(weapon)
	weapon.is_active = true
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
