class_name Projectile
extends Node2D

@onready var sprite_2d = $Sprite2D
@onready var animated_sprite_2d = %AnimatedSprite2D

var _target_set = false
var _target_mob: Mob
var _damage: int
var _is_destroyed = false
var _on_hit_callbacks: Array[Callable]


func _process(_delta):
	if not _target_set || _is_destroyed:
		return

	if !_target_mob:
		_target_set = false
		_destroy_with_animation()
		return

	global_position = global_position.move_toward(
		_target_mob.position, 
		100 * Game.speed_scaled_delta)

	if global_position.distance_squared_to(_target_mob.position) < 1:
		_destroy_with_animation()

		for on_hit in _on_hit_callbacks:
			on_hit.call()

		_target_mob.take_damage(_damage)


func set_target(target_mob: Mob):
	_target_mob = target_mob
	_target_set = true


func add_on_hit_callback(on_hit_callback: Callable):
	_on_hit_callbacks.append(on_hit_callback)


func set_damage(value: int):
	_damage = value


func _destroy_with_animation():
	# Source: https://ask.godotengine.org/56667/how-do-queue_free-but-only-after-animation-has-fully-played
	_is_destroyed = true

	animated_sprite_2d.play("die")
	await animated_sprite_2d.animation_finished
	queue_free()
