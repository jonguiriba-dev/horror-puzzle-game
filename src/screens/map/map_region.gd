extends Control
class_name Region

@export_file("*.tscn") var scene
@onready var label := $RegionLabel
@onready var area := $Area2D


func _on_area_2d_mouse_entered() -> void:
	print("TEST")
	pass # Replace with function body.
