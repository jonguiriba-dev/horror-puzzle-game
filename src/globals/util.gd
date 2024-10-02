extends Node

func get_nearest_in_group(pos:Vector2,group:String):
	var entities := get_tree().get_nodes_in_group(group)
	if entities.size() <= 0:
		return null
	
	var nearest = entities[0]
	for entity in entities:
		if entity is Node2D:
			var new_distance = pos.distance_to(entity.position)
			var old_distance = pos.distance_to(nearest.position)
			if new_distance < old_distance:
				nearest = entity
	return nearest
