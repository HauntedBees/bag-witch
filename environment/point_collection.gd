class_name PointCollection3D extends Path3D

var _points: Array[Vector3] = []

func get_points() -> Array[Vector3]:
	if _points.size() > 0:
		return _points
	for i in curve.point_count:
		_points.append(global_position + global_transform.basis * curve.get_point_position(i))
	return _points
