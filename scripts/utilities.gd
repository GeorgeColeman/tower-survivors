# -----------------------------------------------
# General utilities, not specific to this project
# -----------------------------------------------

class_name Utilities


static func distance_between(point_a: Vector2, point_b: Vector2) -> float:
	return sqrt((point_b.x - point_a.x) ** 2 + (point_b.y - point_a.y) ** 2)


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
