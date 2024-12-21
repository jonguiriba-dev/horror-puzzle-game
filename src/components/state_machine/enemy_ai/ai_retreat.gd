extends AIAttackState
class_name AIRetreatState

var heatmap = []

func _ready() -> void:
	super()
	state_id = C.STATE.AI_RETREAT
	
func analyze_tile_scores():
	if Debug.highlight_enemy_target and is_instance_valid(target):
		WorldManager.grid.set_highlight(
			target.map_position,
			Grid.HIGHLIGHT_COLORS.NONE,
			Grid.HIGHLIGHT_LAYERS.DEBUG
		)
	
	target = null
	
	var scored_tiles = []
	var targets = host.get_enemies()
	print(host.entity_name, " targets ", targets.map(func (e):return e.entity_name))
	
	if targets.size() == 0:
		return scored_tiles
	
	targets.map(func (e:Node):
		var distance = Util.get_pathfinding_distance(e.map_position,host.map_position)
		e.set_meta("distance_to_host",distance)
	)
	
	targets.sort_custom(func(target1, target2):
		return target1.get_meta("distance_to_host") <= target2.get_meta("distance_to_host") 
	)
	var threat_tiles = get_threat_tiles()
	for _target in targets:
		if threat_tiles.has(_target.map_position):
			targets.erase(_target)
			targets.push_back(_target)
		
	var nearest = targets[0]
	if !nearest:
		return scored_tiles
	
	print("targets> ",targets)
	target = nearest
	print(host.entity_name, " is targeting ", nearest.entity_name)
	
	if Debug.highlight_enemy_target:
		WorldManager.grid.set_highlight(
			target.map_position,
			Grid.HIGHLIGHT_COLORS.BLUE,
			Grid.HIGHLIGHT_LAYERS.DEBUG
		)
	
	path_to_nearest_target = WorldManager.grid.get_nearest_path(
		WorldManager.grid.local_to_map(host.position), 
		WorldManager.grid.local_to_map(nearest.position)
	)
	
	#if no path, then try to get as close as possbile by disregarding obstacles 
	if path_to_nearest_target.size() == 0:
		path_to_nearest_target = WorldManager.grid.get_nearest_path(
			WorldManager.grid.local_to_map(host.position), 
			WorldManager.grid.local_to_map(nearest.position),
			false
		)
	heatmap = get_heat_map()
	var moveable_tiles = host.get_ability("move").get_target_tiles()
	moveable_tiles.push_front(host.map_position)
	for tile in moveable_tiles:
		scored_tiles.push_front({
			"position": tile,
			"value": get_tile_value(tile)
		})
	
	var current_tile_value = get_tile_value(host.map_position)
	
	#remove less than the current standing tile value (preferr to stay on the same tile)
	scored_tiles = scored_tiles.filter(func (e):
		return e.value > current_tile_value
	)
	scored_tiles.sort_custom(
		func(a,b):
			return a.value > b.value
	)
	return scored_tiles

func get_heat_map():
	var _heatmap = []
	
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENEMIES):
		if entity == host:
			continue
		for x in range(-3,3):
			for y in range(-3,3):
				var value
				if abs(x) > abs(y):
					value = (abs((x * 10))  - 40) * 0.2
				else:
					value = (abs((y * 10))  - 40) * 0.2
					
				var new_map_pos = entity.map_position + Vector2i(x,y)
				var entry = _heatmap.filter(func (e):return e.tile == new_map_pos)
				if entry.size() > 0:
					entry[0].value += value
				else:
					_heatmap.push_front(
						{
							"tile": new_map_pos,
							"value": value 
						}
					)
	return _heatmap
	
func get_tile_value(tile_pos:Vector2i)->int:
	var value = 0
	
	var direction = Util.get_direction(host.map_position,tile_pos)
	
	var bounds = WorldManager.get_world_bounds()
	
	match(WorldManager.starting_position):
		C.DIRECTION.NORTH:
			value += abs((tile_pos.y-bounds.position.y) - bounds.size.y) * 8 
		C.DIRECTION.SOUTH:
			value += tile_pos.y * 8 
		C.DIRECTION.WEST:
			value += abs((tile_pos.x-bounds.position.x) - bounds.size.x) * 8 
		C.DIRECTION.EAST:
			value += tile_pos.x * 8 
			
	value += Util.get_manhattan_distance(host.map_position,tile_pos) * 4
	
	for entry in heatmap:
		if entry.tile == tile_pos:
			value += entry.value
			break
			
	return value
