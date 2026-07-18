@tool
extends GridMap

## Points that need to be logging when generating things, for debugging purposes.
const _DEBUG_LOGGIES: Array[Vector3] = [Vector3(9.0, 0.0, -17.0)]

#const _WALLS: PackedInt32Array = [174, 175, 176, 177]
const _CORNERS: PackedInt32Array = [
	202, 203, # T-walls
	180, 181, 182 # regular corners
]
const _GAPS: PackedInt32Array = [179] # hole
#const _ROTATIONS: PackedInt32Array = [10, 16, 0, 22]
const _SCALE := 4.0
const _NAME := "WallCollider"
const _WALL_HEIGHT := 12.0 / _SCALE
const _CENTER_OFFSET := Vector3(2.0, 7.0, 2.0)

@export_tool_button("Bake Wall Collisions", "StaticBody3D") var btn = _bake

func _bake() -> void:
	var scene_root := get_tree().edited_scene_root
	var parent := get_parent()
	print("Creating CSGCombiner3D node.")
	var combiner := CSGCombiner3D.new()
	parent.add_child(combiner)
	combiner.owner = scene_root
	print("Baking")
	var straight_lines: Array[Line] = []
	var cells := get_used_cells()
	cells.sort_custom(func(a: Vector3, b: Vector3) -> bool:
		if a.z == b.z:
			return a.x < b.x
		return a.z < b.z
	)
	for pos in cells:
		var tile := get_cell_item(pos)
		if _GAPS.has(tile):
			continue
		var point_lines := get_lines_for_point(pos, straight_lines)
		var num_lines := point_lines.size()
		var do_debug_log := _DEBUG_LOGGIES.has(pos)
		if do_debug_log:
			print("Tile %s (type %s) has %s line(s)." % [pos, tile, num_lines])
			for l in point_lines:
				print("from %s to %s" % [l.start, l.end])
		match num_lines:
			0:
				straight_lines.append(Line.new(pos))
				if do_debug_log: print("starting a line here")
				if _CORNERS.has(tile): # corners go in twice
					if do_debug_log: print("starting a second line here since it's a corner")
					straight_lines.append(Line.new(pos))
			1:
				point_lines[0].append(pos)
				if do_debug_log: print("continuing the line here")
				if _CORNERS.has(tile): # corners go in twice
					if do_debug_log: print("and starting a second line here since it's a corner")
					straight_lines.append(Line.new(pos))
			_:
				var was_point: Array[bool] = []
				for i in num_lines:
					was_point.append(point_lines[i].is_point())
				point_lines[0].append(pos)
				if do_debug_log: print("continuing the first line here")
				for i in range(1, num_lines):
					if was_point[i - 1] && was_point[i]:
						if do_debug_log: print("skipping the next line here")
						continue
					else:
						if do_debug_log: print("continuing the next line here")
						point_lines[i].append(pos)
	for i in straight_lines.size():
		var l := straight_lines[i]
		var b := CSGBox3D.new()
		var line_length := l.length()
		if l.direction == Vector3.RIGHT:
			b.size = _SCALE * Vector3(line_length, _WALL_HEIGHT, 0.5)
		else:
			b.size = _SCALE * Vector3(0.5, _WALL_HEIGHT, line_length)
		b.name = "%s%d" % [_NAME, i]
		b.position = l.center()
		combiner.add_child(b)
		b.owner = scene_root
		#print("line goes from %s to %s (dir %s)" % [l.start, l.end, l.direction])
	print("Bake Complete")
	var col := CollisionShape3D.new()
	col.shape = combiner.bake_collision_shape()
	col.name = "WallCollisions"
	parent.add_child(col)
	col.owner = scene_root
	combiner.free()
	print("Collision Shape Created")

func get_lines_for_point(point: Vector3, lines: Array[Line]) -> Array[Line]:
	var point_lines: Array[Line] = []
	for l in lines:
		# Potential second point; just check if it's next to it.
		if l.direction == Vector3.ZERO:
			if abs(point.distance_to(l.end)) == 1.0:
				point_lines.append(l)
		# Otherwise point must just be the next point in that direction.
		elif (l.end + l.direction) == point:
			point_lines.append(l)
	return point_lines

class Line:
	var start: Vector3
	var end: Vector3
	var points: PackedVector3Array = []
	var direction := Vector3.ZERO

	func _init(st: Vector3) -> void:
		start = st
		end = st
		points.append(st)

	func is_point() -> bool:
		return start == end

	func equal(l: Line) -> bool:
		return l.start == start && l.end == end && l.direction == direction && l.points.size() == points.size()

	func length() -> float:
		return end.distance_to(start)

	func center() -> Vector3:
		return _SCALE * (start + end) / 2.0 + _CENTER_OFFSET

	func append(p: Vector3) -> void:
		points.append(p)
		end = p
		if points.size() == 2:
			direction = points[1] - points[0]
