extends Node

func get_nearest_in_group(pos:Vector2,group:String):
	var nodes := get_tree().get_nodes_in_group(group)
	nodes.filter(func(e):
		if is_instance_valid(e):
			return true
		return false
	)

	if nodes.size() <= 0:
		return null
	
	var nearest = nodes[0]
	for node in nodes:
		if node is Entity:
			var entity = node as Entity
			var new_distance = pos.distance_to(entity.position)
			var old_distance = pos.distance_to(nearest.position)
			if new_distance < old_distance:
				nearest = entity
	return nearest
