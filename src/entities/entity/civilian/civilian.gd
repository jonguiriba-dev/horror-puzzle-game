extends Entity
class_name Civilian

signal rescued

func _ready() -> void:
	super()
	add_to_group(C.GROUPS_CIVILIANS)
	add_to_group(C.GROUPS_TARGETS)
	rescued.connect(_on_rescued)
	
func _on_rescued():
	print("rescued", entity_name)
	queue_free()

func _on_area_2d_mouse_entered() -> void:
	super()

func _on_area_2d_mouse_exited() -> void:
	super()
	hide_all_details()
		
