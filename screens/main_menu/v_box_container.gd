extends VBoxContainer

@onready var cont := $Label
@onready var new_game := $Label4
@onready var options := $Label2
@onready var exit := $Label3


	 
func _ready()->void:
	print("here")
	new_game.connect("gui_input",_on_click_new_game)
	
func _on_click_new_game(event: InputEvent)->void:
	print("here")
	if(event.is_action_pressed("click")):
		SceneManager.change_scene("game")
		print("TEST",event.as_text())
