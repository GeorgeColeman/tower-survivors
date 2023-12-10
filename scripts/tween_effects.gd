class_name TweenEffects

static func flash_white(node_2d: Node2D, default_color: Color):
	var tween = node_2d.get_tree().create_tween()
	tween.tween_property(node_2d, "modulate", Color.WHITE * 10, 0.05)
	tween.tween_property(node_2d, "modulate", default_color, 0.05)
