extends Control
class_name MapUI

@onready var menu_button := $MenuButton
@onready var party_button := $PartyButton

signal menu_button_pressed
signal party_button_pressed

func _ready() -> void:
	menu_button.pressed.connect(_on_menu_button_pressed)
	party_button.pressed.connect(_on_party_button_pressed)
	
func _on_menu_button_pressed():
	menu_button_pressed.emit()
	var menu_node = preload(Menu.MENU_TSCN).instantiate()
	menu_node = menu_node as Control
	add_child(menu_node)
	menu_node.global_position = DisplayServer.window_get_size()/2

func _on_party_button_pressed():
	party_button_pressed.emit()
	SceneManager.change_scene("res://src/screens/manage_roster/ManageRoster.tscn")
