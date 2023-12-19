class_name SpecialEffects
extends Node2D

@export var floating_text_scene: PackedScene


var show_damage_text = false:
	set(value):
		show_damage_text = value


func _ready():
	Messenger.floating_text_requested.connect(_instantiate_floating_text)


func _instantiate_floating_text(message: String, p_position: Vector2, effect_type: int):
	match effect_type:
		EffectType.DAMAGE_NUMBER:
			if !show_damage_text:
				return

	var new_floating_text = floating_text_scene.instantiate() as Label
	add_child(new_floating_text)

	var offset = -Vector2(new_floating_text.size * 0.5)
	new_floating_text.position = p_position + offset
	new_floating_text.text = message

	# Tween docs: https://docs.godotengine.org/en/stable/classes/class_tween.html
	var tween = get_tree().create_tween().set_parallel(true)
	# NOTE: you can hover a property in the inspector to see its name
	tween.tween_property(new_floating_text, "position", new_floating_text.position + Vector2.UP * 8, 1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(new_floating_text, "modulate:a", 0, 1).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(new_floating_text.queue_free)
