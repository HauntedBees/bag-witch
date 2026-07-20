class_name PortalWisp extends WorldItem

@onready var _warp_orb: MeshInstance3D = %WarpOrb
@onready var _warp_mat: ShaderMaterial = _warp_orb.get_active_material(0)

func bind_from_inventory_portal(i: PortalItem) -> void:
	item = i
	if !is_inside_tree():
		await ready
	_warp_mat.set_shader_parameter(&"texture_albedo", i.portal_image)
