extends Control
class_name Game

@export_file() var game_scene
@onready var game_node = $SubViewportContainer/SubViewport/Root
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
	
	SceneManager.register_game_node(game_node)
	if game_scene:
		SceneManager.change_scene(game_scene)
		
