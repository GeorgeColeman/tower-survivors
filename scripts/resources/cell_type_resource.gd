class_name CellTypeResource
extends Resource

@export var main_texture: Texture2D
@export var alt_texture: Array[Texture2D] = []


func get_random_texture() -> Texture2D:
	var rand = randi_range(0, 50)

	if rand < 50:
		return main_texture

	return alt_texture.pick_random()
