class_name VFXDrawer2D
extends Node2D

enum EffectType {
	DAMAGE_NUMBER,
	FIRE_BURST
}

static var _instance: VFXDrawer2D

@export var floating_text_scene: PackedScene
@export var fire_burst_scene: PackedScene


var show_damage_text = false:
	set(value):
		show_damage_text = value


static func request_vfx(
	effect_type: EffectType,
	p_position: Vector2,
	message: String = "",
	colour: Color = Color.WHITE
):
	match effect_type:
		EffectType.DAMAGE_NUMBER:
			_instance._instantiate_floating_text(message, p_position, colour)
		EffectType.FIRE_BURST:
			_instance._instantiate_vfx(_instance.fire_burst_scene, p_position)


func _ready():
	_instance = self


func _instantiate_vfx(scene: PackedScene, p_position: Vector2):
	var new_vfx = scene.instantiate() as Node2D
	add_child(new_vfx)

	new_vfx.position = p_position

	var timer = get_tree().create_timer(1)
	timer.timeout.connect(
		func():
			new_vfx.queue_free()
	)


func _instantiate_floating_text(message: String, p_position: Vector2, colour: Color):
	if !show_damage_text:
		return

	var new_floating_text = floating_text_scene.instantiate() as Label
	add_child(new_floating_text)
	
	new_floating_text.modulate = colour

	var offset = -Vector2(new_floating_text.size * 0.5)
	new_floating_text.position = p_position + offset
	new_floating_text.text = message

	# Tween docs: https://docs.godotengine.org/en/stable/classes/class_tween.html
	var tween = get_tree().create_tween().set_parallel(true)
	# NOTE: you can hover a property in the inspector to see its name
	tween.tween_property(new_floating_text, "position", new_floating_text.position + Vector2.UP * 8, 1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(new_floating_text, "modulate:a", 0, 1).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(new_floating_text.queue_free)
