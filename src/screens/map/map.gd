extends Control

@onready var map := $Map
func _ready() -> void:
	for child in get_children():
		if child is Region:
			print("child ", child)
			child.area.mouse_entered.connect(_on_region_area_entered.bind(child))
			child.area.mouse_exited.connect(_on_region_area_exited.bind(child))
func _on_party_button_pressed() -> void:
	SceneManager.change_scene("res://src/screens/manage_roster/ManageRoster.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var region = get_tree().get_first_node_in_group(C.GROUPS_HOVERED_REGIONS)
		if region:
			SceneManager.change_scene(region.scene)
			
		
func _on_region_area_entered(region) -> void:
	print("enter")
	Util.sysprint("Map","region hovered:%s"%[region.name])
	region.add_to_group(C.GROUPS_HOVERED_REGIONS)
	region.label.position += Vector2(0,-10) 
	
func _on_region_area_exited(region) -> void:
	print("exit")
	region.label.position += Vector2(0,10) 
	Util.sysprint("Map","region exited:%s"%[region.name])
	region.remove_from_group(C.GROUPS_HOVERED_REGIONS)


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("sadfasdfasd") # Replace with function body.


func _on_area_2d_mouse_entered() -> void:
	print("123") # Replace with function body.
	pass # Replace with function body.


func _on_area_2d_mouse_exited() -> void:
	print("456") # Replace with function body.
	pass # Replace with function body.
