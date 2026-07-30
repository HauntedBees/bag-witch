class_name FinalCutscene extends Cutscene

@export var queen: Node3D
@export var queen_anim: AnimationPlayer
@export var boss: TheBoss
@export var item_spawner: GenerationalItemSpawner
@export var enemy_spawner: GenerationalEnemySpawner

func _init_cutscene() -> void:
	queen_anim.play(&"Idle")
	var player: Node3D = get_tree().get_first_node_in_group(&"PlayerCharacter")
	if player:
		queen.look_at(player.global_position)
		queen.rotate_y(PI)
	SignalBus.text_ended.connect(_on_finish_queen_dialog_a, CONNECT_ONE_SHOT)
	SignalBus.say_thing.emit("Queen Perpetua XII", "Oh, hey! Didn't see you there! It seems the travelled has become... the traveller!", "QP12a")
	SignalBus.say_thing.emit("Queen Perpetua XII", "Anyway I guess now you've thwarted my family's plans of using animals to power our time-and-space-travel technology.", "QP12b")
	SignalBus.say_thing.emit("Queen Perpetua XII", "Which sucks.", "QP12c")
	SignalBus.say_thing.emit("Queen Perpetua XII", "For you, mostly. Look around you... does this look like a throne room to you?", "QP12d")
	SignalBus.say_thing.emit("Queen Perpetua XII", "A big... empty... windowless room? With a bunch of platforms in it?! You think I chill here for fun?!", "QP12e")
	SignalBus.say_thing.emit("Queen Perpetua XII", "No, you fool, this is where you will die!", "QP12f")
	boss.on_died.connect(_on_boss_died)

func _on_finish_queen_dialog_a() -> void:
	boss.poof()
	queen.look_at(boss.global_position)
	queen.rotate_y(PI)
	SignalBus.text_ended.connect(_on_finish_queen_dialog_b, CONNECT_ONE_SHOT)
	SignalBus.say_thing.emit("Queen Perpetua XII", "Now we're talking!", "QP12g")
	queen_anim.play(&"Cheer")

func _on_finish_queen_dialog_b() -> void:
	var player: BogWitch = get_tree().get_first_node_in_group(&"PlayerCharacter")
	if player:
		queen.look_at(player.global_position)
		queen.rotate_y(PI)
	SignalBus.text_ended.connect(_on_finish_queen_dialog_c, CONNECT_ONE_SHOT)
	SignalBus.say_thing.emit("Queen Perpetua XII", "Get ready to die, you old witch!", "QP12h")
	queen_anim.play(&"Idle_Combat")

func _on_finish_queen_dialog_c() -> void:
	queen_anim.play_backwards(&"Spawn_Ground")
	var t := create_tween()
	t.tween_interval(1.0)
	t.tween_callback(boss.show_queen)
	t.tween_interval(1.0)
	t.tween_callback(func() -> void:
		boss.activate()
		item_spawner.regen_time = 10.0
		enemy_spawner.visible = true
		var boss_music: AudioStream = load("uid://6vlbkpbsonkh")
		SignalBus.change_looping_song.emit(boss_music, boss_music, 0.125)
	)

func _on_boss_died() -> void:
	SignalBus.text_ended.connect(_on_finish_queen_dialog_d, CONNECT_ONE_SHOT)
	SignalBus.say_thing.emit("Queen Perpetua XII", "Noo! How could this happen?!", "QP12i")
	SignalBus.say_thing.emit("Queen Perpetua XII", "If only there were time for the developer to give me a more satisfying defeat!!", "QP12j")
	SignalBus.say_thing.emit("Queen Perpetua XII", "Curse youuuuuuu!", "QP12k")

func _on_finish_queen_dialog_d() -> void:
	_finish_cutscene(true)
	SignalBus.say_thing.emit("Bag Witch", "I think I deserve a nice long nap after that.", "QP12l")
