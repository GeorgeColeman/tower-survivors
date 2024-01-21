class_name Tower
extends Node2D

signal was_killed()

#@export var tower_name: String
@export var graphics: Node2D
@export var hit_points_component: HitPointsComponent
@export var animation_player: AnimationPlayer
@export var firing_point: Marker2D
@export var show_hit_points_bar: bool = true

var tower_resource: TowerResource

var tower_name: String:
	get:
		return tower_resource.name

var kills: int
var cell: Cell
var tower_stats: TowerStats
var weapon_dict = {}										# <String, TowerWeapon>

var _weapons: Array[TowerWeapon] = []
var _is_destroyed: bool
var _rank: int = 1

var description: String:
	get:
		var d = "Rank %s" % _rank

		for weapon in _weapons:
			d += str("\n\n", weapon.weapon_name, "\n", weapon.description)

		return d

var weapons_description: String:
	get:
		var s = ""

		for weapon in _weapons:
			s += str(weapon.weapon_name, "\n", weapon.description, "\n\n")

		return s.substr(0, s.length() - 2)


func uninstantiate():
	# TODO: kill tweens (if any)
	queue_free()


func set_resource(p_tower_resource: TowerResource):
	tower_resource = p_tower_resource

	hit_points_component.initialise(p_tower_resource.hit_points, show_hit_points_bar)

	for weapon in p_tower_resource.weapons:
		var weapon_data: TowerWeaponData = GameData.get_tower_weapon_data(weapon)

		if !weapon_data:
			return

		var weapon_node = TowerWeapon.new()
		weapon_node.set_data(weapon_data)

		_attach_weapon(weapon_node)


func set_cell_and_init(p_cell: Cell):
	cell = p_cell
	tower_stats = TowerStats.new(_weapons)

	for weapon in _weapons:
		_activate_weapon(weapon)


func get_cells_in_attack_range() -> Array[Cell]:
	if _weapons.size() == 0:
		#print_debug("No weapons")

		return []

	return _weapons[0]._cells_in_range


func set_rank(value: int):
	_rank = value


func add_rank(amount: int):
	_rank += amount


func attach_weapon_from_weapon_data(weapon_data: TowerWeaponData):
	var weapon_node = TowerWeapon.new()
	weapon_node.set_data(weapon_data)

	_attach_weapon(weapon_node)
	_activate_weapon(weapon_node)


func _attach_weapon(weapon: TowerWeapon):
	add_child(weapon)
	_weapons.append(weapon)

	if weapon_dict.has(weapon.id):
		print_debug("WARNING: weapon dict already has ", weapon.id)

		return

	weapon_dict[weapon.id] = weapon


func _activate_weapon(weapon: TowerWeapon):
	weapon.set_cell(cell)
	weapon.set_firing_point(firing_point.position)

	weapon.is_active = true


func take_damage(amount: int):
	hit_points_component.change_current(-amount)

	if hit_points_component.is_at_zero:
		_destroy()

	if graphics:
		TweenEffects.flash_white(graphics, Color.WHITE)
	else:
		print_debug("TODO: graphics node for tower: %s" % tower_name)


func _destroy():
	_is_destroyed = true
	was_killed.emit()

	if animation_player:
		animation_player.play("destroy")

	# Deactivate weapons
	for weapon in _weapons:
		weapon.is_active = false
