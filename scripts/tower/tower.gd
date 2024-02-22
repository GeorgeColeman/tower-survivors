class_name Tower
extends Node2D

signal description_updated(description: String)
signal was_killed(tower: Tower)

@export var graphics: Node2D
@export var hit_points_component: HitPointsComponent
@export var firing_point: Marker2D
@export var show_hit_points_bar: bool = true

var tower_resource: TowerResource

var tower_name: String:
	get:
		return tower_resource.name

var kills: int
var cell: Cell
var base_cells: Array[Cell]
var tower_stats: TowerStats
var rank: Rank
var weapon_dict = {}										# <String, TowerWeapon>

var _weapons: Array[TowerWeapon] = []
var _passive_upgrade_dict = {}								# <String, PassiveUpgrade>
var _is_destroyed: bool

var description: String:
	get:
		var d = "Rank %s" % rank.display_rank

		for weapon in _weapons:
			d += str("\n\n", weapon.weapon_name, "\n", weapon.description)

		d += "\n"

		for upgrade in _passive_upgrade_dict.values():
			d += "\n%s: %s" % [upgrade.name, upgrade.display_rank]

		d = d.strip_edges()

		return d

var weapons_description: String:
	get:
		var s = ""

		for weapon in _weapons:
			s += str(weapon.weapon_name, "\n", weapon.description, "\n\n")

		return s.substr(0, s.length() - 2)


func _init():
	rank = Rank.new()


func uninstantiate():
	# TODO: kill tweens (if any)
	queue_free()


func set_resource(p_tower_resource: TowerResource):
	tower_resource = p_tower_resource

	hit_points_component.initialise(p_tower_resource.hit_points, show_hit_points_bar)

	for weapon in p_tower_resource.weapons:
		var weapon_data: TowerWeaponData = DataUtilities.get_weapon_data(weapon)

		if !weapon_data:
			return

		var weapon_node: TowerWeapon

		# Determine the type of tower weapon to attach
		match weapon_data.targeting_type:
			Enums.TargetingType.SEEKING:
				weapon_node = TowerWeaponProjectile.new()
			Enums.TargetingType.LINE:
				weapon_node = TowerWeaponProjectile.new()
			Enums.TargetingType.AREA:
				weapon_node = TowerWeaponArea.new()
			Enums.TargetingType.MORTAR:
				weapon_node = TowerWeaponProjectile.new()
			_:
				var unknown_type = Enums.TargetingType.get(weapon_data.targeting_type)
				print_debug("WARNING: unknown targeting type: %s" % unknown_type)

				return

		weapon_node.set_data(weapon_data)

		_attach_weapon(weapon_node)


func set_cell_and_init(p_cell: Cell, p_base_cells: Array[Cell]):
	cell = p_cell
	base_cells = p_base_cells
	tower_stats = TowerStats.new(_weapons)
	#rank = Rank.new()

	rank.rank_added.connect(
		func(current_rank: int):
			description_updated.emit(description)
	)

	for weapon in _weapons:
		_activate_weapon(weapon)


func get_entity_info() -> EntityInfo:
	return EntityInfo.new(
			self,
			tower_name,
			description,
			position
	)


func get_cells_in_attack_range() -> Array[Cell]:
	if _weapons.size() == 0:
		return []

	return _weapons[0]._cells_in_range


func attach_weapon_from_weapon_data(weapon_data: TowerWeaponData):
	var weapon_node = TowerWeapon.new()
	weapon_node.set_data(weapon_data)

	_attach_weapon(weapon_node)
	_activate_weapon(weapon_node)


func add_passive_upgrade(passive_upgrade: PassiveUpgradeTowerAttached):
	_passive_upgrade_dict[passive_upgrade.name] = passive_upgrade


func get_passive_upgrade(passive_upgrade_name: String) -> PassiveUpgradeTowerAttached:
	if !_passive_upgrade_dict.has(passive_upgrade_name):
		return null

	return _passive_upgrade_dict[passive_upgrade_name]


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
	was_killed.emit(self)

	# Deactivate weapons
	for weapon in _weapons:
		weapon.is_active = false
