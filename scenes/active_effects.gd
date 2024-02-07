class_name ActiveEffects
extends Node2D


static var _instance: ActiveEffects

@export var _acid_sprite_frames: SpriteFrames


func _ready():
	_instance = self


static func create_acid_effect(cell: Cell):
	var acid_effect_visual = AnimatedSprite2D.new()

	_instance.add_child(acid_effect_visual)

	acid_effect_visual.position = cell.scene_position
	acid_effect_visual.sprite_frames = _instance._acid_sprite_frames

	_instance.get_tree().create_timer(1).timeout.connect(
		func():
			acid_effect_visual.queue_free()
	)

	push_warning("TODO: make acid do something")
