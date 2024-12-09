extends Control
class_name Game

@export_file() var game_scene
@onready var root = $SubViewportContainer/SubViewport/Root
@onready var audio_player = $AudioStreamPlayer
@onready var audio_player2 = $AudioStreamPlayer2
@onready var audio_player3 = $AudioStreamPlayer3
@onready var audio_player4 = $AudioStreamPlayer4
@onready var music_player = $MusicStreamPlayer

func _ready():
	MusicManager.registerAudioPlayer(music_player)
	SfxManager.registerAudioPlayer(audio_player)
	SfxManager.registerAudioPlayer(audio_player2)
	SfxManager.registerAudioPlayer(audio_player3)
	SfxManager.registerAudioPlayer(audio_player4)
	if game_scene:
		var node = load(game_scene).instantiate()
		node.size_flags_vertical = SIZE_SHRINK_CENTER
		node.size_flags_horizontal = SIZE_SHRINK_CENTER
		root.add_child(node)
	
	
