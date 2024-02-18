class_name AcidPool
extends Node2D

@export var _area: Area2D

var _duration: float
var _damage_per_tick: int
var _tick_speed: float
var _cell: Cell

var _elapsed: float
var _tick_elapsed: float = 0.0001			# Adding this ensures that damage ticks the correct number of times

var _total_ticks: int


func init(duration: float, damage_per_tick: int, tick_speed: float, cell: Cell):
	_duration = duration
	_damage_per_tick = damage_per_tick
	_tick_speed = tick_speed
	_cell = cell


func _ready():
	_area.area_entered.connect(_on_area_entered)
	_area.area_exited.connect(_on_area_exited)


func _process(delta):
	_tick_elapsed += delta

	if _tick_elapsed >= _tick_speed:
		_total_ticks += 1

		# Apply damage to all mobs on the cell
		for mob in MobUtilities.get_mobs_at(_cell):
			var damage_info = DamageInfoFactory.new_damage_info(_damage_per_tick)

			mob.take_damage(damage_info)

		_tick_elapsed = _tick_elapsed - _tick_speed


	_elapsed += delta

	if _elapsed >= _duration:
		queue_free()
		#print_debug("Acid pool dispersed. Number of ticks: %s" % _total_ticks)


func _on_area_entered(area: Area2D):
	if area is MobBody:
		#area.take_damage_deferred(get_damage.call())
		print_debug("Mob body entered area")

func _on_area_exited(area: Area2D):
	pass
