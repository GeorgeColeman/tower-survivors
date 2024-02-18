class_name ActiveEffects
extends Node2D

static var _instance: ActiveEffects

@export var _acid_pool_scene: PackedScene

#@export var _acid_sprite_frames: SpriteFrames


func _ready():
	_instance = self


static func add_effect(effect: Node2D):
	_instance.add_child(effect)


static func create_acid_effect(
	duration: float,
	damage_per_tick: int,
	tick_speed: float,
	cell: Cell
):

	var acid_pool = _instance._acid_pool_scene.instantiate()
	acid_pool.init(
		duration,
		damage_per_tick,
		tick_speed,
		cell
	)

	_instance.add_child(acid_pool)

	acid_pool.position = cell.scene_position

	#var acid_effect_visual = AnimatedSprite2D.new()
#
	#_instance.add_child(acid_effect_visual)
#
	#acid_effect_visual.position = cell.scene_position
	#acid_effect_visual.sprite_frames = _instance._acid_sprite_frames
#
	#_instance.get_tree().create_timer(1).timeout.connect(
		#func():
			#acid_effect_visual.queue_free()
	#)
#
	#push_warning("TODO: make acid do something")

	# Create periodic effect
