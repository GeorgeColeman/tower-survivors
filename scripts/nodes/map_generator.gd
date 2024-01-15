class_name MapGenerator


func generate_map(width: int, height: int) -> Map:
	var cells: Array[Cell] = []

	var noise = FastNoiseLite.new()
	var scale = 10

	noise.seed = randi()

	var min: float
	var max: float

	var samples: Array[float]

	for y in height:
		for x in width:
			var index = x + y * width

			cells.append(Cell.new(index, x, y))

			var sample = noise.get_noise_2d(x * scale, y * scale)

			samples.append(sample)

			if sample > max:
				max = sample
			elif sample < min:
				min = sample

	var range = max - min

	var radial = _radial_gradient(width, height, width * 0.25)

	#print_debug(radial[width * 0.5 + height * 0.5 * width])

	for y in height:
		for x in width:
			var index = x + y * width
			#samples[x + y * width] = ((samples[index] - min) / range)
			var h = lerpf((samples[index] - min) / range, 0.5, radial[index])
			samples[x + y * width] = h
			#samples[x + y * width] = ((samples[index] - min) / range) * radial[index]

	return Map.new(width, height, cells, samples)


func _radial_gradient(width: int, height: int, max_distance: int) -> Array[float]:
	var grad: Array[float] = []
	grad.resize(width * height)
	var centre: Vector2 = Vector2(width * 0.5, height * 0.5)

	for y in height:
		for x in width:
			var dist = sqrt(pow(x - centre.x, 2) + pow(y - centre.y, 2))
			var norm_dist = dist / max_distance

			grad[x + y * width] = clampf(1 - norm_dist, 0, 1)
			#grad[x + y * width] = 1 - norm_dist

	return grad
