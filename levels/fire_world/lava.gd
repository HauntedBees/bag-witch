class_name Lava extends Area3D

const _SMOKE_SCENE := preload("uid://bce761tpdiksy")
const _FREEZE_SCENE := preload("uid://ewoeuy06x4v4")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is BogWitch:
		body.take_damage(999)
	elif body is LavaSlime:
		body.lava_up()
	elif body is EnemyDisplay:
		body.take_specific_damage(9999)
	print("LAVA BODY %s" % body.name)

func _on_area_entered(area: Area3D) -> void:
	var parent: Node3D = area.get_parent()
	if parent == null:
		return
	if parent is Projectile:
		var effect := (parent as Projectile).effect
		if effect == BWEnum.Effect.Burn:
			_add_smoke(parent, false)
		elif effect == BWEnum.Effect.Freeze:
			var freeze_block: Node3D = _FREEZE_SCENE.instantiate()
			add_child(freeze_block)
			freeze_block.global_position = parent.global_position

func _add_smoke(body: Node3D, extreme: bool) -> void:
	var smoke: SmokeCloud = _SMOKE_SCENE.instantiate()
	smoke.extreme = extreme
	body.add_child(smoke)
	smoke.global_position = body.global_position
