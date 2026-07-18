class_name ModdableWeaponDisplay extends WorldItem

@onready var _silencer_slot: Node3D = %SilencerSlot
@onready var _scope_slot: Node3D = %ScopeSlot
@onready var _clip_slot: Node3D = %ClipSlot

func bind(id: InventoryDetail) -> void:
	if !is_inside_tree():
		await ready
	_silencer_slot.visible = false
	_scope_slot.visible = false
	_clip_slot.visible = false
	for m in id.modifications:
		match m.mod_name:
			&"Silencer": _silencer_slot.visible = true
			&"Scope": _scope_slot.visible = true
			&"Clip": _clip_slot.visible = true
