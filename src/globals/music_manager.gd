extends Node

var audio_player:AudioStreamPlayer

func play(_name:String):
	match _name:
		"bg-music-battle-1":
			audio_player.set_stream(preload("res://assets/audio/bg-music/bg-music-battle-2.ogg"))
			audio_player.play()

func registerAudioPlayer(_audio_player:AudioStreamPlayer):
	self.audio_player = _audio_player
