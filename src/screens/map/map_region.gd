extends Control
class_name Region

@export_file("*.tscn") var scene
@onready var label := $RegionLabel
@onready var area := $Area2D
@onready var select_anchor := $SelectAnchor
@onready var area_collision_polygon :CollisionPolygon2D= $Area2D/CollisionPolygon2D
var active_location:RegionLocation

func ready():
	pass

func _on_area_2d_mouse_entered() -> void:
	pass # Replace with function body.

func randomize_active_location():
	var locations = []
	for child in get_children():
		if child is RegionLocation:
			locations.push_front(child)
	
	if locations.size() > 0:
		active_location = locations.pick_random()
