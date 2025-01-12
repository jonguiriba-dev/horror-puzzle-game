extends AIAttackState
class_name AIForward

func _ready() -> void:
	super()
	state_id = C.STATE.AI_FORWARD
	

func find_target():
	return get_farthest_target()	
	
func get_farthest_target():
	var targets = host.get_enemies()
	
	var bounds = WorldManager.level.get_world_bounds()
	var bound_pos
	
	match(WorldManager.level.starting_position):
		C.DIRECTION.NORTH:
			bound_pos = Vector2i(
				host.map_position.x,
				(bounds.size.y-1)+bounds.position.y
			)
		C.DIRECTION.SOUTH:
			bound_pos = Vector2i(
				host.map_position.x,
				(0)+bounds.position.y
			)
		C.DIRECTION.WEST:
			bound_pos = Vector2i(
				(bounds.size.x-1)+bounds.position.x,
				host.map_position.y
			)
		C.DIRECTION.EAST:
			bound_pos = Vector2i(
				(0)+bounds.position.x,
				host.map_position.y
			)
	
	targets.map(func (e:Node):
		var distance = Util.get_manhattan_distance(e.map_position,bound_pos)
		e.set_meta("distance_to_bounds",distance)
	)
	
	targets.sort_custom(func(target1, target2):
		return target1.get_meta("distance_to_bounds") <= target2.get_meta("distance_to_bounds") 
	)
	var threat_tiles = get_threat_tiles()
	for _target in targets.duplicate():
		if threat_tiles.has(_target.map_position):
			targets.erase(_target)
			targets.push_back(_target)
		
	var nearest = targets[0]
	return nearest
	
