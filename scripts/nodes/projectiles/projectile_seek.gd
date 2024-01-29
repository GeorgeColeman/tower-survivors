extends Projectile

@export var animated_sprite_2d: AnimatedSprite2D
@export var test_curve: Curve
@export var arc_height = 16.0

var _target_set = false
var _target_mob: Mob
var _target_position: Vector2
var _damage: int
var _is_destroyed = false

var _approx_time_to_hit: float
var _to_hit_progress: float


func _process(_delta):
	if not _target_set || _is_destroyed:
		return

	if !_target_mob:
		_target_set = false
		_destroy_with_animation()
		return

	global_position = global_position.move_toward(
		_target_mob.position,
		_speed * Game.speed_scaled_delta
	)

	_to_hit_progress += Game.speed_scaled_delta

	if _to_hit_progress > _approx_time_to_hit:
		_to_hit_progress = _approx_time_to_hit

	animated_sprite_2d.position.y = -test_curve.sample(
		_to_hit_progress / _approx_time_to_hit) * arc_height

	if global_position.distance_squared_to(_target_mob.position) < 1:
		_destroy_with_animation()

		var hit_info = TowerWeaponHitInfo.new()

		hit_info.cells.append(_target_mob.cell)
		hit_info.mobs.append(_target_mob)

		apply_weapon_effects_to_hit(hit_info)

		_target_mob.take_damage(DamageInfoFactory.new_damage_info(_damage))


func set_target(target_mob: Mob):
	_target_mob = target_mob
	_target_position = target_mob.position
	_target_set = true

	var distant_to_mob = global_position.distance_to(target_mob.position)

	_approx_time_to_hit = distant_to_mob / _speed


func set_damage(value: int):
	_damage = value


func _destroy_with_animation():
	# Source: https://ask.godotengine.org/56667/how-do-queue_free-but-only-after-animation-has-fully-played
	_is_destroyed = true

	animated_sprite_2d.play("die")
	await animated_sprite_2d.animation_finished
	queue_free()
