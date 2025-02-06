extends Control

@onready var abilities := $Anchor/Abilities
@onready var abilities_list := $Anchor/Abilities/VBoxContainer

func _on_map_button_pressed() -> void:
	SceneManager.change_scene("res://src/screens/map/Map.tscn")

func _on_training_button_pressed() -> void:
	pass
	
func _ready() -> void:
	for child in abilities_list.get_children():
		child.queue_free()
	
	for ability_prop in PlayerManager.inventory.get("abilities",[]):
		var label = Label.new()
		abilities_list.add_child(label)
		label.text = ability_prop.ability_name


func _on_training_button_endurance_pressed() -> void:
	#TrainingManager.train_health()
	pass # Replace with function body.


func _on_training_button_lecture_pressed() -> void:
	#TrainingManager.train_experience()
	pass # Replace with function body.


func _on_training_button_sparring_pressed() -> void:
	#TrainingManager.train_ability()
	pass # Replace with function body.
