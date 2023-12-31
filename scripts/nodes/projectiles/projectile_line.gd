# ----------------------------------------------------
# A projectile that travels in a line towards a target
# ----------------------------------------------------

extends Projectile

@export var _area_2d: Area2D

@export var _duration: float = 1.5
@export var _speed: float = 100

var _direction: Vector2
var _life_time: float

var _damage: int


func _ready():
	_area_2d.area_entered.connect(
		func(area: Area2D):
			#print_debug("Area entered: ", area)
			if area is MobBody:
				#area.take_damage(DamageInfoFactory.new_damage_info(_damage))
				area.take_damage_deferred(DamageInfoFactory.new_damage_info(_damage))
				#print_debug("Hit mob body")
	)


func _process(_delta):
	_life_time += Game.speed_scaled_delta

	if _life_time >= _duration:
		queue_free()

	translate(_direction * _speed * Game.speed_scaled_delta)


func set_target(target_mob: Mob):
	_direction = (target_mob.global_position - global_position).normalized()


func add_on_hit_callback(_on_hit_callback: Callable):
	pass


func set_damage(value: int):
	_damage = value
