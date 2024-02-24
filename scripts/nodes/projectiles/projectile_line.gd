# ----------------------------------------------------
# A projectile that travels in a line towards a target
# ----------------------------------------------------

extends Projectile

@export var _area_2d: Area2D

var _range: int
var _duration: float
var _direction: Vector2
var _life_time: float


func _ready():
	_area_2d.area_entered.connect(
		func(area: Area2D):
			#print_debug("Area entered: ", area)
			if area is MobBody:
				call_deferred("_hit_mob_body", area)
	)


func _hit_mob_body(mob_body: MobBody):
	if mob_body.is_immune:
		return

	mob_body.take_damage(get_damage.call())

	var hit_info = TowerWeaponHitInfo.new()

	hit_info.cells.append(mob_body.mob.nearest_cell)
	hit_info.mobs.append(mob_body.mob)

	apply_weapon_effects_to_hit(hit_info)


func _process(_delta):
	_life_time += Game.speed_scaled_delta

	if _life_time >= _duration:
		queue_free()

	translate(_direction * _speed * Game.speed_scaled_delta)


func set_target(target_mob: Mob):
	_direction = (target_mob.global_position - global_position).normalized()


func set_range(value: int):
	_range = value

	_update_duration()


func set_speed(speed: float):
	super.set_speed(speed)

	_update_duration()


func _update_duration():
	_duration = _range / (_speed * GameConstants.UNITS_PER_PIXEL)
