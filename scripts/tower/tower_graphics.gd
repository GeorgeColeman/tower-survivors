class_name TowerGraphics
extends Node2D

@export var _animated_sprite_2d: AnimatedSprite2D

var _anim_dict = {}


func _ready():
	for anim in _animated_sprite_2d.sprite_frames.animations:
		_anim_dict[anim.name] = anim


func take_damage(_amount: int):
	TweenEffects.flash_white(_animated_sprite_2d, Color.WHITE)


func play_animation_once(animation_name: String):
	if !_anim_dict.has(animation_name):
		print_debug("WARNING: no animation: %s" % animation_name)

		return

	_animated_sprite_2d.play(animation_name)
	
	await _animated_sprite_2d.animation_finished
	
	_animated_sprite_2d.play("default")
	
