extends AIAttackState
class_name AIFarthest

var heatmap = []

func _ready() -> void:
	super()
	state_id = C.STATE.AI_FARTHEST
	

func find_target():
	return get_farthest_target()	
	
func get_farthest_target():
	var targets = host.get_enemies()
	print(host.entity_name, " targets ", targets.map(func (e):return e.entity_name))
	
	targets.map(func (e:Node):
		var distance = Util.get_pathfinding_distance(e.map_position,host.map_position)
		e.set_meta("distance_to_host",distance)
	)
	
	targets.sort_custom(func(target1, target2):
		return target1.get_meta("distance_to_host") >= target2.get_meta("distance_to_host") 
	)
	var threat_tiles = get_threat_tiles()
	for _target in targets:
		if threat_tiles.has(_target.map_position):
			targets.erase(_target)
			targets.push_back(_target)
		
	var nearest = targets[0]
	return nearest
	
