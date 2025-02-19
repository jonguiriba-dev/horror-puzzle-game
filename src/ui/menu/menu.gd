extends Control
class_name Menu

const MENU_TSCN = "res://src/ui/menu/menu.tscn"

@onready var exit_button := $VBoxContainer/ExitToMainMenu
@onready var options_button := $VBoxContainer/Options

func _ready() -> void:
	print("READY MENU")
	exit_button.pressed.connect(_on_exit_to_main_menu_pressed)
	options_button.pressed.connect(_on_options_pressed)

func _on_exit_to_main_menu_pressed():
	print("_on_exit_to_main_menu_pressed")
	SceneManager.change_scene(SceneManager.SCENE_MAIN_MENU,false)
	
func _on_options_pressed():
	SceneManager.change_scene(SceneManager.SCENE_MAIN_MENU,false)
