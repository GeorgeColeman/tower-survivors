class_name ActiveEffects
extends Node2D

static var _instance: ActiveEffects

@export var _acid_pool_scene: PackedScene


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
