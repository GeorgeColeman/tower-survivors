class_name MapGenerator


func generate_map(width: int, height: int) -> Map:
	var cells: Array[Cell] = []

	for y in height:
		for x in width:
			var index = x + y * width

			cells.append(Cell.new(index, x, y))

	return Map.new(width, height, cells)
