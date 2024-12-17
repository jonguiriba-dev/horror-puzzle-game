extends Node
var audio_players:Array[AudioStreamPlayer]=[]

func play(_name:String):
	var audio_player = audio_players[0]
	if audio_player.has_stream_playback():
		audio_player = audio_players[1]
	if audio_player.has_stream_playback():
		audio_player = audio_players[2]
	if audio_player.has_stream_playback():
		audio_player = audio_players[3]
	audio_player.volume_db = 0
	audio_player.pitch_scale = 1
	
	var sound
	match _name:
		"hit-1":
			sound = preload("res://assets/audio/sfx/sfx-hit-chime-1.wav")
		"hit-2":
			sound = preload("res://assets/audio/sfx/sfx-hit-chime-2.wav")
			audio_player.volume_db = -4
			audio_player.pitch_scale = 1.4
		"hit-crunch-1":
			sound = preload("res://assets/audio/sfx/sfx-hit-crunch-1.mp3")
			audio_player.volume_db = -4
		"step-1":
			sound = preload("res://assets/audio/sfx/sfx-step-1.wav")
		"step-2":
			sound = preload("res://assets/audio/sfx/sfx-step-2.wav")
			audio_player.volume_db = -4
		"charge-1":
			sound = preload("res://assets/audio/sfx/sfx-charge-in-1.wav")
		"charge-2":
			sound = preload("res://assets/audio/sfx/sfx-charge-in-2.wav")
		"charge-3":
			sound = preload("res://assets/audio/sfx/sfx-charge-in-3.wav")
		"charge-4":
			sound = preload("res://assets/audio/sfx/sfx-charge-in-4.wav")
			audio_player.volume_db = 2
		"grunt-girl-1":
			sound = preload("res://assets/audio/sfx/sfx-grunt-girl-1.wav")
	
	audio_player.set_stream(sound)
	audio_player.play()
	
func registerAudioPlayer(_audio_player:AudioStreamPlayer):
	audio_players.push_front(_audio_player) 
