extends Node


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func get_nearest(pos:Vector2,nodes:Array):
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

func get_direction(source:Vector2i,target:Vector2i)->Vector2i:
	var direction = (source - target)
	print(">>>> ",direction)
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0: 
			direction.x = 1 
		else:
			direction.x = -1
		direction.y = 0
	else:
		if direction.y > 0: 
			direction.y = 1 
		else:
			direction.y = -1
		direction.x = 0
		
	return direction
