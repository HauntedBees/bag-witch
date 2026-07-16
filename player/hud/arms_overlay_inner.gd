class_name ArmsOverlayInner extends Node3D

signal set_suck(on: bool)

@onready var _anim: AnimationPlayer = %AnimationPlayer
@onready var _right_hand: BoneAttachment3D = %RightHand
@onready var _left_hand: BoneAttachment3D = %LeftHand
@onready var _bag: Node3D = %bag

func _ready() -> void:
	Player.equip_changed.connect(_on_weapon_changed)

func reset_idle() -> void:
	_bag.visible = false
	set_suck.emit(false)
	var w: Item = Player.data.current_equipped_item()
	if w == null || w.equipped_animation == "":
		_anim.play(&"Idle")
	else:
		_anim.play(w.equipped_animation)

func play_anim(anim: StringName, return_to_idle := true) -> void:
	_bag.visible = anim == &"BagUse" || anim == &"BagSuck"
	set_suck.emit(anim == &"BagSuck")
	_anim.play(anim)
	if return_to_idle:
		await _anim.animation_finished
		reset_idle()

func _on_weapon_changed(id: InventoryDetail) -> void:
	for n in _right_hand.get_children():
		if n == _bag:
			continue
		n.queue_free()
	for n in _left_hand.get_children():
		n.queue_free()
	var w: Item = null if id == null else id.item
	if w == null:
		_anim.play(&"Idle")
		return
	if w.equipped_animation == "":
		_anim.play(&"Idle")
	else:
		_anim.play(w.equipped_animation)
	_add_to_bone(_right_hand, w)
	if w.add_equip_scene_to_both_hands:
		_add_to_bone(_left_hand, w)

func _add_to_bone(n: BoneAttachment3D, w: Item) -> void:
	var attachment := w.get_equip_instance()
	attachment.scale *= w.equipped_scale
	n.add_child(attachment)
