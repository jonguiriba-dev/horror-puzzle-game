extends Entity
class_name Civilian

signal rescued

func _ready() -> void:
	super()
	add_to_group(C.GROUPS.CIVILIANS)
	rescued.connect(_on_rescued)
	
func _on_rescued():
	print("rescued", entity_name)
	queue_free()

func _on_area_2d_mouse_entered() -> void:
	super()
	var targetting_entity = get_tree().get_first_node_in_group(C.GROUPS.TARGETTING_ENTITY)
	if(targetting_entity is Unit):
		print("HERE")
		var is_within_range = targetting_entity.get_reachable_tiles(targetting_entity.move_range).has(WorldManager.active_tilemap.get_map_mouse_position())
		if is_within_range:
			show_detail("rescue")
		
func _on_area_2d_mouse_exited() -> void:
	super()
	hide_all_details()
		
