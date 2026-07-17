@tool
extends GridMap

#const _WALLS: PackedInt32Array = [174, 175, 176, 177]
const _CORNERS: PackedInt32Array = [
	202, 203, # T-walls
	180, 181, 182 # regular corners
]
#const _ROTATIONS: PackedInt32Array = [10, 16, 0, 22]
const _SCALE := 4.0
const _NAME := "WallCollider"
const _WALL_HEIGHT := 12.0 / _SCALE
const _CENTER_OFFSET := Vector3(2.0, 7.0, 2.0)

@export_tool_button("Bake Wall Collisions", "StaticBody3D") var btn = _bake
@export var combiner: CSGCombiner3D

func _bake() -> void:
	if combiner == null:
		printerr("Select a CSGCombiner3D node first.")
		return
	var scene_root := get_tree().edited_scene_root
	print("Clearing Old Wall CollisionShapes")
	for p in combiner.get_children():
		if p.name.begins_with(_NAME):
			p.free()
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
		#var orientation := get_cell_item_orientation(pos)
		var line := find_point_for_line(pos, straight_lines)
		if line == null:
			if _CORNERS.has(tile): # corners go in twice
				straight_lines.append(Line.new(pos))
				straight_lines.append(Line.new(pos))
		else:
			if _CORNERS.has(tile) && count_points_for_line(pos, straight_lines) == 1:
				straight_lines.append(Line.new(pos))
			line.append(pos)
		print("tile at %s is %s" % [pos, tile])
		#print("tile at %s is %s, orientation %s" % [pos, tile, orientation])
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
		print("line goes from %s to %s (dir %s)" % [l.start, l.end, l.direction])
	print("Bake Complete")

func find_point_for_line(point: Vector3, lines: Array[Line]) -> Line:
	for l in lines:
		# Potential second point; just check if it's next to it.
		if l.direction == Vector3.ZERO:
			if abs(point.distance_to(l.end)) == 1.0:
				return l
		# Otherwise point must just be the next point in that direction.
		elif (l.end + l.direction) == point:
			return l
	return null

func count_points_for_line(point: Vector3, lines: Array[Line]) -> int:
	var count := 0
	for l in lines:
		# Potential second point; just check if it's next to it.
		if l.direction == Vector3.ZERO:
			if abs(point.distance_to(l.end)) == 1.0:
				count += 1
		# Otherwise point must just be the next point in that direction.
		elif (l.end + l.direction) == point:
			count += 1
	return count

class Line:
	var start: Vector3
	var end: Vector3
	var points: PackedVector3Array = []
	var direction := Vector3.ZERO

	func _init(st: Vector3) -> void:
		start = st
		end = st
		points.append(st)

	func length() -> float:
		return end.distance_to(start)

	func center() -> Vector3:
		return _SCALE * (start + end) / 2.0 + _CENTER_OFFSET

	func append(p: Vector3) -> void:
		points.append(p)
		end = p
		if points.size() == 2:
			direction = points[1] - points[0]
