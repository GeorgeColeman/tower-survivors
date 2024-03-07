class_name WalkableRegions
extends RefCounted

var _width: int
var _height: int
var _get_is_walkable: Callable				# is_walkable(x: int, y: int) -> bool:

var _regions: Array[Region]
var _checked_points = {}


func _init(width: int, height: int, get_is_walkable: Callable):
	_width = width
	_height = height
	_get_is_walkable = get_is_walkable


func establish_regions():
	_regions.clear()
	_checked_points.clear()

	var largest_point_count: int

	for y in _height:
		for x in _width:
			var index = x + y * _width

			if _checked_points.has(index):
				continue

			_checked_points[index] = true

			if !_get_is_walkable.call(x, y):
				continue

			var region = _get_region_at_walkable_start(x, y)

			if region.points.size() > largest_point_count:
				largest_point_count = region.points.size()
				region.is_largest_region = true

				for ex_region in _regions:
					ex_region.is_largest_region = false

			_regions.append(region)

	#print_debug("Regions established. Number of regions: %s" % _regions.size())
#
	#for region in _regions:
		#print_debug(region.points.size())


func _get_region_at_walkable_start(start_x: int, start_y: int) -> Region:
	var region = Region.new()
	var open: Array[Vector2i]

	open.append(Vector2i(start_x, start_y))

	while open.size() > 0:
		var point: Vector2i = open.pop_back()
		region.points.append(point)
		_checked_points[point.x + point.y * _width] = true

		# Check neighbouring points
		if _check_point(point.x, point.y + 1):
			open.append(Vector2i(point.x, point.y + 1))
		if _check_point(point.x, point.y - 1):
			open.append(Vector2i(point.x, point.y - 1))
		if _check_point(point.x + 1, point.y):
			open.append(Vector2i(point.x + 1, point.y))
		if _check_point(point.x - 1, point.y):
			open.append(Vector2i(point.x - 1, point.y))

	return region


func _check_point(x: int, y: int) -> bool:
	if x < 0 || x >= _width || y < 0 || y >= _height:
		return false

	var index = x + y * _width

	if _checked_points.has(index):
		return false

	# Add point to checked points to ensure that it is not added more than once
	_checked_points[index] = true

	if !_get_is_walkable.call(x, y):
		return false

	return true



class Region:

	var points: Array[Vector2i]
	var is_largest_region: bool


	func has_point(point: Vector2i):
		return points.has(point)
