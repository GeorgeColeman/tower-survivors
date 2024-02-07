# -------------------------------------------------------------
# A projectile that flies through the air and lands at a target
# -------------------------------------------------------------

extends Projectile

@export var _die_time: float
@export var _animated_sprite_2d: AnimatedSprite2D

var _area_radius: int = 2				# FIXME: magic number

var _range: int
var _duration: float
var _direction: Vector2
var _life_time: float

var _target_mob: Mob
var _target_cell: Cell

var _is_destroyed = false


func _process(_delta):
	if _is_destroyed:
		return

	_life_time += Game.speed_scaled_delta

	if _life_time >= _duration:
		_hit_target_cell()
		#queue_free()

	translate(_direction * _speed * Game.speed_scaled_delta)


func set_target(target_mob: Mob):
	_direction = (target_mob.global_position - global_position).normalized()

	_target_mob = target_mob
	_target_cell = target_mob.nearest_cell
	#_target_cell = target_mob.cell


func set_range(value: int):
	_range = value


func set_speed(speed: float):
	super.set_speed(speed)

	_update_duration()


func _update_duration():
	_duration = global_position.distance_to(_target_mob.position) / _speed

	#print_debug("Mortar duration: %s" % _duration)


func _hit_target_cell():
	var cells_in_area = GameUtilities.get_cells_in_circle(_target_cell, _area_radius)
	var all_targets = GameUtilities.get_all_targets_in_cells(cells_in_area)

	# The projectile determines what is part of its hit info. This is good
	var hit_info = TowerWeaponHitInfo.new()

	hit_info.cells = cells_in_area
	hit_info.mobs = all_targets

	apply_weapon_effects_to_hit(hit_info)

	for target in all_targets:
		target.take_damage(get_damage.call())

	_destroy_with_animation()


func _destroy_with_animation():
	# Source: https://ask.godotengine.org/56667/how-do-queue_free-but-only-after-animation-has-fully-played
	_is_destroyed = true

	_animated_sprite_2d.play("die")

	await _animated_sprite_2d.animation_finished

	queue_free()
