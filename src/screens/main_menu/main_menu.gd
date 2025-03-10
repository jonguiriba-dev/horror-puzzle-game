extends Control

@onready var continue_label := $VBoxContainer/ContinueLabel
@onready var new_game_label := $VBoxContainer/NewGameLabel
@onready var options_label := $VBoxContainer/OptionsLabel
@onready var exit_label := $VBoxContainer/ExitLabel

var selected_label 


func _enter_tree() -> void:
	UIManager.clear_ui()

func _ready() -> void:
	for label in [continue_label,new_game_label,options_label,exit_label]:
		label.mouse_entered.connect(_on_label_mouse_entered.bind(label))
		label.mouse_exited.connect(_on_label_mouse_exited)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		print("selected_label ",selected_label)
		if selected_label == continue_label:
			SaveManager.load_data()
		if selected_label == new_game_label:
			SaveManager.reset_save_data()
			SceneManager.change_scene(SceneManager.SCENES.MAP)
			PlayerManager.load_starting_units()
		if selected_label == options_label:
			UIManager.show_menu()
			
		if selected_label == exit_label:
			get_tree().quit()
func _on_label_mouse_entered(label:Label):
	print("label entered ",label)
	selected_label = label
		
func _on_label_mouse_exited():
	selected_label = null
