class_name OpeningCutscene extends Cutscene

@export var book: Item
@export var animals: CutsceneAnimals

@export var suspense_song: AudioStream
@export var arm: BadGuyArm

@export var queen: LazyAnim
@export var knight1: LazyAnim
@export var knight2: LazyAnim

@export var convo_trigger: Area3D
@export var portal_pos: Marker3D
@export var knight1_pos: Marker3D
@export var knight2_pos: Marker3D

func _init_cutscene() -> void:
	Player.input_locked = true
	Player.inventory_available = false
	Player.equip_changed.emit(InventoryDetail.new(book, Vector2i.ZERO))
	convo_trigger.body_entered.connect(func(b: Node3D) -> void:
		if b is BogWitch:
			if b.grace_period > 0.01:
				return
			_on_start_conversation()
	)
	queen.set_anim(&"Idle", true)
	knight1.set_anim(&"Rig_Medium_General/Idle_B", true)
	knight2.set_anim(&"Rig_Medium_General/Idle_B", true)
	var t := create_tween()
	t.tween_interval(5.0)
	arm.grabbed.connect(_on_lunged, CONNECT_ONE_SHOT)
	arm.done.connect(_on_left, CONNECT_ONE_SHOT)
	t.tween_callback(func() -> void:
		arm.lunge()
	)

func _on_lunged() -> void:
	SignalBus.change_song.emit(suspense_song, 0.125)
	#TODO: squeaky sound
	Player.equip_changed.emit(null)
	animals.queue_free()
	animals = null

func _on_left() -> void:
	Player.input_locked = false
	arm.queue_free()
	arm = null

func _on_start_conversation() -> void:
	SignalBus.text_ended.connect(_on_finish_queen_dialog, CONNECT_ONE_SHOT)
	SignalBus.say_thing.emit("Queen Perpetua I", "Verily, these beestes sholde do well.", "QP1")
	SignalBus.say_thing.emit("Queen Perpetua I", "Bryng them thru. We shal make good use of them.", "QP2")

func _on_finish_queen_dialog() -> void:
	queen.set_anim(&"Walking_A", true)
	var dest := _clamp_to_y(portal_pos, queen)
	var k1_dest := _clamp_to_y(knight1_pos, knight1)
	var k2_dest := _clamp_to_y(knight2_pos, knight2)
	_look_at_rot(queen, dest)
	var t := create_tween()
	t.tween_property(queen, "global_position", dest, 3.0)
	t.tween_callback(func() -> void:
		queen.queue_free()
		queen = null
		_look_at_rot(knight1, k1_dest)
		_look_at_rot(knight2, k2_dest)
		knight1.set_anim(&"Rig_Medium_MovementBasic/Walking_B", true)
		knight2.set_anim(&"Rig_Medium_MovementBasic/Walking_B", true)
	)
	t.set_parallel(true)
	t.tween_property(knight1, "global_position", k1_dest, 1.0)
	t.tween_property(knight2, "global_position", k2_dest, 1.0)
	t.set_parallel(false)
	t.tween_callback(func() -> void:
		_look_at_rot(knight1, dest)
		_look_at_rot(knight2, dest)
	)
	t.set_parallel(true)
	t.tween_property(knight1, "global_position", dest, 2.0)
	t.tween_property(knight2, "global_position", dest, 2.5)
	t.set_parallel(false)
	t.tween_callback(func() -> void:
		knight1.queue_free()
		knight1 = null
		knight2.queue_free()
		knight2 = null
		_finish_cutscene(true)
		SignalBus.say_thing.emit("Bag Witch", "How dare that pompous royal take those animals! I need ta' put a stop to this!", "BW1")
	)

func _clamp_to_y(source: Node3D, y_source: Node3D) -> Vector3:
	var pos := source.global_position
	pos.y = y_source.global_position.y
	return pos

func _look_at_rot(n: Node3D, p: Vector3) -> void:
	n.look_at(p)
	n.rotate_y(PI)
