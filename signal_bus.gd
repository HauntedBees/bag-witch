extends Node

@warning_ignore("unused_signal")
signal portal_entered()

@warning_ignore("unused_signal")
signal load_new_level(destination_uid: String, destination_point_name: String)

@warning_ignore("unused_signal")
signal game_over()

#region Cutscene
@warning_ignore("unused_signal")
signal say_thing(speaker: String, text: String, id: String)

@warning_ignore("unused_signal")
signal say_new_item_text(speaker: String, text: String)

@warning_ignore("unused_signal")
signal text_advanced(new_id: String)

@warning_ignore("unused_signal")
signal text_ended()
#endregion

#region Sound
@warning_ignore("unused_signal")
signal change_song(song: AudioStream, transition_secs: float)

@warning_ignore("unused_signal")
signal change_looping_song(open: AudioStream, loop: AudioStream, transition_secs: float)

@warning_ignore("unused_signal")
signal play_sound(sound: AudioStream)

@warning_ignore("unused_signal")
signal stop_all_sounds()
#endregion
