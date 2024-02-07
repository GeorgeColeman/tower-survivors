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
				area.take_damage_deferred(get_damage.call())

				print_debug("TODO: apply weapon effects")

				if !_does_pass:
					queue_free()

				#print_debug("Hit mob body")
	)


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
