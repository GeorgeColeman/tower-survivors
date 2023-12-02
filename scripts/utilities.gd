class_name Utilities


static func get_world_position(cell: Cell) -> Vector2:
	return Vector2(cell.x, cell.y) * GameConstants.PIXEL_SCALE


static func get_converted_position(position: Vector2) -> Vector2:
	return position * GameConstants.PIXEL_SCALE


static func get_random_unique_elements(array: Array, number_of_elements: int) -> Array:
	var unique_elements = []
	var seen = {}

	if number_of_elements >= array.size():
		return array

	while unique_elements.size() < number_of_elements:
		var random_index = randi() % array.size()
		var element = array[random_index]

		if not seen.has(element):
			unique_elements.append(element)
			seen[element] = true

	return unique_elements


# Source: https://www.youtube.com/watch?v=56I72m5wDj4
static func get_function_runtime(callable: Callable) -> float:
	var start_time = Time.get_ticks_msec()
	callable.call()
	var end_time = Time.get_ticks_msec()
	return end_time - start_time
