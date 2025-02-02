extends Control

@onready var abilities := $Anchor/Abilities
@onready var abilities_list := $Anchor/Abilities/VBoxContainer

func _on_map_button_pressed() -> void:
	SceneManager.change_scene("res://src/screens/map/Map.tscn")

func _ready() -> void:
	for child in abilities_list.get_children():
		child.queue_free()
	
	for ability_prop in PlayerManager.inventory.get("abilities",[]):
		var label = Label.new()
		abilities_list.add_child(label)
		label.text = ability_prop.ability_name
