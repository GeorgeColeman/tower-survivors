class_name ScuffedPoissonDiscSampling


static func generate_points(radius: float, width: float, height: float, retries: int = 30) -> PackedVector2Array:
	var cell_size: float = radius / sqrt(2)
	var cols: int = max(floor(width / cell_size), 1)
	var rows: int = max(floor(height / cell_size), 1)

	var grid: Array = []
	for i in cols:
		grid.append([])
		for j in rows:
			grid[i].append(-1)

	var points: PackedVector2Array = PackedVector2Array()
	var spawn_points: Array = []

	# Add the centre of the area as the first spawn point
	spawn_points.append(Vector2(width * 0.5, height * 0.5))

	var sample_region_size: Vector2 = Vector2(width, height)

	while spawn_points.size() > 0:
		var spawn_index: int = randi() % spawn_points.size()
		var spawn_centre: Vector2 = spawn_points[spawn_index]
		var point_accepted: bool = false

		for i in retries:
			var angle: float = 2 * PI * randf()
			var sample: Vector2 = spawn_centre + Vector2(cos(angle), sin(angle)) * (radius + radius * randf())

			if _is_valid(sample, sample_region_size, cell_size, radius, points, grid):
				print_debug("is valid")
				points.append(sample)
				spawn_points.append(sample)
				grid[int(sample.x / cell_size)][int(sample.y / cell_size)] = points.size()
				point_accepted = true

				break

		if !point_accepted:
			spawn_points.remove_at(spawn_index)

	return points

static func _is_valid(point: Vector2, sample_region_size: Vector2, cell_size: float, radius: float, points: Array, grid: Array):
	if point.x >= 0 && point.x < sample_region_size.x && point.y >= 0 && point.y < sample_region_size.y:
		var cell_x: int = (int)(point.x / cell_size)
		var cell_y: int = (int)(point.y / cell_size)
		
		var cell_start := Vector2(max(0, cell_x - 2), max(0, cell_y - 2))
		var cell_end := Vector2(min(cell_x + 2, sample_region_size.x - 1), min(cell_y + 2, sample_region_size.y - 1))

		for x in range(cell_start.x, cell_end.x + 1):
			for y in range(cell_start.y, cell_end.y + 1):
				var point_index: int = grid[x][y]
				if point_index != -1:
					print_debug(points.size(), " :: ", point_index)
					var sqrDst: float = points[point_index - 1].distance_squared_to(point)
	
					if sqrDst < radius * radius:
						return false

		return true

	return false
