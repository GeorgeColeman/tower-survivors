class_name TweenEffects

static func flash_white(sprite_2d: Sprite2D, default_color: Color):
	var tween = sprite_2d.get_tree().create_tween()
	tween.tween_property(sprite_2d, "modulate", Color.WHITE * 10, 0.05)
	tween.tween_property(sprite_2d, "modulate", default_color, 0.05)
