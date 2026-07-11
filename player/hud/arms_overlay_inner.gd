class_name ArmsOverlayInner extends Node3D

@onready var _anim: AnimationPlayer = %AnimationPlayer
@onready var _right_hand: BoneAttachment3D = %RightHand
@onready var _left_hand: BoneAttachment3D = %LeftHand

func _ready() -> void:
	Player.weapon_changed.connect(_on_weapon_changed)

func reset_idle() -> void:
	var w: Weapon = Player.data.current_weapon()
	if w == null || w.equipped_animation == "":
		_anim.play(&"Idle")
	else:
		_anim.play(w.equipped_animation)

func play_anim(anim: StringName, return_to_idle := true) -> void:
	_anim.play(anim)
	if return_to_idle:
		await _anim.animation_finished
		reset_idle()

func _on_weapon_changed(id: InventoryDetail) -> void:
	var w: Weapon = id.item
	for n in _right_hand.get_children():
		n.queue_free()
	for n in _left_hand.get_children():
		n.queue_free()
	if w == null:
		_anim.play(&"Idle")
		return
	if w.equipped_animation == "":
		_anim.play(&"Idle")
	else:
		_anim.play(w.equipped_animation)
	_add_to_bone(_right_hand, w)
	if w.both_hands:
		_add_to_bone(_left_hand, w)

func _add_to_bone(n: BoneAttachment3D, w: Weapon) -> void:
	var attachment := w.get_equip_instance()
	attachment.scale *= w.equipped_scale
	n.add_child(attachment)
