class_name Tower
extends Node2D

signal was_killed()

@export var hit_points_component: HitPointsComponent

@export var main_sprite_2d: Sprite2D
@export var starting_weapons: Array[PackedScene]
@export var max_hit_points := 50 as int
@export var gold_cost: int = 20
@export var starting_upgrade_points := 1 as int
@export var animation_player: AnimationPlayer
@export var firing_point: Marker2D
@export var level_progress_bar: TextureProgressBar

#@onready var green_arrow = %GreenArrow as Node2D

var draw_range_indicators = false:
	set(value):
		draw_range_indicators = value

		for weapon in _weapons:
			weapon.draw_range_indicators = value

var kills: int

var has_upgrade_points: bool:
	get:
		return _upgrade_points > 0

var _upgrade_points: int
var experience: int
var level: int = 1
var exp_to_next_level: int = 10
var perc_to_next_level: float:
	get:
		return (experience as float / exp_to_next_level) * 100

var cell: Cell
var tower_stats: TowerStats

var _weapons: Array[TowerWeapon] = []
var _upgrade_tween: Tween
var _is_destroyed: bool
var _rank: int = 1

var _current_upgrade_options: UpgradeOptions

var description: String:
	get:
		return "Rank %s" % _rank


func _ready():
#	main_sprite_2d.offset = GameUtilities.calculate_sprite_offset(main_sprite_2d)
	pass


func clear_upgrade_options():
#	print_debug("Clearing upgrade options")
	_current_upgrade_options = null


func get_upgrade_options() -> UpgradeOptions:
	if !_current_upgrade_options || _current_upgrade_options.option_is_chosen:
#		print_debug("Generating new upgrade options")
		_current_upgrade_options = GameUtilities.get_upgrade_options(3)

	return _current_upgrade_options


func add_upgrade(upgrade: UpgradeResource):
	if _current_upgrade_options.option_is_chosen:
		print_debug("Upgrade option is already chosen")
		pass

	upgrade.add_to_tower(self)
	add_or_remove_upgrade_points(-1)
	_current_upgrade_options.option_is_chosen = true


func uninstantiate():
	# It appears any running tweens must be destroyed before queue free
	if _upgrade_tween:
		_upgrade_tween.kill()

	queue_free()


func set_cell_and_init(p_cell: Cell):
	cell = p_cell

	hit_points_component.initialise(max_hit_points, true)
	tower_stats = TowerStats.new(_weapons)

	for weapon in starting_weapons:
		var new_weapon = weapon.instantiate() as TowerWeapon
		_attach_weapon(new_weapon)

	Messenger.mob_killed.connect(_on_mob_killed)

	_update_level_progress_bar()

	# Tween stuff: https://docs.godotengine.org/en/stable/classes/class_tween.html
	#_upgrade_tween = get_tree().create_tween().set_loops()
	#_upgrade_tween.tween_property(green_arrow, "position", Vector2.UP * 8, 1).set_trans(Tween.TRANS_SINE)
	#_upgrade_tween.tween_property(green_arrow, "position", Vector2.ZERO, 1).set_trans(Tween.TRANS_SINE)

	add_or_remove_upgrade_points(starting_upgrade_points)


func set_rank(value: int):
	_rank = value


func add_or_remove_upgrade_points(amount: int):
	_upgrade_points += amount

	#green_arrow.visible = true if _upgrade_points > 0 else false


func _on_mob_killed(mob: Mob):
	_add_kill()


func _update_level_progress_bar():
	if !level_progress_bar:
		return

	level_progress_bar.value = perc_to_next_level


func _add_kill():
	kills += 1
	#experience += 1
#
	## Check if the tower has leveled up
	#if experience >= exp_to_next_level:
		#_level_up()
#
	#_update_level_progress_bar()


func _level_up():
	experience -= exp_to_next_level
	var additional_exp = floori(exp_to_next_level * 0.1) + 5
	exp_to_next_level += additional_exp
	#print_debug("FIXME: arbitrary additional exp formula. Exp to next: ", exp_to_next_level)
	level += 1
	add_or_remove_upgrade_points(1)
	Messenger.request_floating_text("Tower leveled up. Current level: %s" % str(level))


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
