class_name Portal extends Node3D

@export var subviewport: SubViewport

## Leave blank if teleporting to same area.
@export_custom(SRP_HINT.RESOURCE_PATH, "PackedScene") var teleport_scene: String

## Leave blank if teleporting to same area.
@export var teleport_point_name: String

var _viewport_cam: Node3D

@onready var _inside: MeshInstance3D = %Inside
@onready var _inside_material: ShaderMaterial = _inside.get_active_material(0)

@onready var _collider: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var _box: BoxShape3D = _collider.shape

func _ready() -> void:
	_viewport_cam = subviewport.get_child(0)
	_inside_material.set_shader_parameter(&"texture_albedo", subviewport.get_texture())

func _process(_delta: float):
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var local := to_local(cam.global_position)
	local.y = 0
	if _viewport_cam != null:
		_viewport_cam.rotation.y = atan2(local.x, -local.z) * 0.25

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not BogWitch:
		return
	SignalBus.portal_entered.emit()
	Player.data.portal_wipe()
	if teleport_scene.is_empty():
		_teleport_local(body)
	else:
		_teleport_distant()

func get_screen_bounds() -> Rect2:
	return BWEnum.get_bounds(global_transform, _box, get_viewport().get_camera_3d())

func _teleport_distant() -> void:
	SignalBus.load_new_level.emit(teleport_scene, teleport_point_name)

func _teleport_local(player: BogWitch) -> void:
	var target_cam: Camera3D = _viewport_cam.get_child(0)
	var delta_yaw := _viewport_cam.global_rotation.y - target_cam.global_rotation.y
	player.velocity = player.velocity.rotated(Vector3.UP, delta_yaw)
	player.cam_holder.global_rotation.y = target_cam.global_rotation.y
	player.cam_holder.camera.global_rotation.x = target_cam.global_rotation.x
	player.global_position = target_cam.global_position
