extends State
class_name AIAttackState

var path_to_nearest_target
var threat
var tile_labels:Array = []
var to_idle = false

func _ready() -> void:
	super()
	state_id = C.STATE.AI_ATTACK
	
func _on_configured():
	host.move_end.connect(_on_host_move_end)
	host.death.connect(_on_host_death)

func _enter_state(old_state, new_state):
	print("attack start")
	to_idle = false
	
	var team_turn = WorldManager.team_turn
	if threat:
		await attack_target()
		
	if team_turn == host.team:
		
		for l in tile_labels:
			l.queue_free()
		tile_labels = []
		
		var scored_tiles = analyze_tile_scores()
		if scored_tiles.size()  == 0:
			return
	
		if Debug.show_enemy_ai_tile_values:
			show_tile_values(scored_tiles)
		
		host.get_ability("move").use(scored_tiles[0].position)

func show_tile_values(scored_tiles:Array):
	for t in scored_tiles:
		var l = Label.new()
		l.z_index=98
		l.text = str(t.value)
		WorldManager.grid.prop_layer.add_child(l)
		l.position = WorldManager.grid.map_to_local(t.position) + Vector2(-8,-8)
		l.set("theme_override_font_sizes/font_size", 10)
		tile_labels.push_front(l)

func _transition():
	if to_idle:
		return C.STATE.AI_IDLE
		
func _on_host_move_end():
	print("_on_host_move_end ")
	apply_threat()
	host.hide_all_details()
	host.turn_end.emit()
	to_idle = true
	
	
func apply_threat():
	for ability in host.get_abilities():
		print("ability ",ability.ability_name)
		var target_count = 0
		if !ability.can_target_entities:
			return
		print("ability ",ability.ability_name)
		var reachable_tiles = ability.get_reachable_tiles(host.map_position,ability.ability_range)
		print("reachable_tiles ",reachable_tiles)
		for target in get_tree().get_nodes_in_group(C.GROUPS_TARGETS):
			if reachable_tiles.has(target.map_position):
				print("reach")
				threat = {"tile":target.map_position, "ability":ability, "target":target}
				WorldManager.grid.set_highlight(target.map_position,Grid.HIGHLIGHT_COLORS.RED,Grid.HIGHLIGHT_LAYERS.THREAT)
				WorldManager.grid.threat_tiles.push_front(threat.tile)
				target_count += 1
				if ability.target_count == target_count:
					return
func attack_target():
	print("attack ")
	await threat.ability.use(threat.tile) 
	WorldManager.grid.set_highlight(threat.tile,Grid.HIGHLIGHT_COLORS.NONE,Grid.HIGHLIGHT_LAYERS.THREAT)
	threat = null
	
func analyze_tile_scores():
	var scored_tiles = []
	var targets = host.get_enemies()

	if targets.size() == 0:
		print(123,get_tree().get_nodes_in_group(C.GROUPS_ENTITIES))
		return scored_tiles
	
	targets.sort_custom(func(target1, target2):
		var distance1 = WorldManager.grid.get_manhattan_distance(target1.position,host.position)
		var distance2 = WorldManager.grid.get_manhattan_distance(target2.position,host.position)
		return distance1 <= distance2
	)
	
	for target in targets:
		WorldManager.grid.debug_tile_text(target.map_position,str(target.position.distance_squared_to(host.position)))
		if WorldManager.grid.threat_tiles.has(target.map_position):
			targets.erase(target)
			targets.push_back(target)
		
	var nearest = targets[0]
	if !nearest:
		return scored_tiles
	
	print(host.entity_name, " is targeting ", nearest.entity_name)
	
	WorldManager.grid.set_highlight(
		WorldManager.grid.local_to_map(nearest.position),
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
	
	var moveable_tile = host.get_ability("move").get_reachable_tiles()
	for tile in moveable_tile:
		scored_tiles.push_front({
			"position": tile,
			"value": get_tile_value(tile)
		})
		
	scored_tiles.sort_custom(
		func(a,b):
			return a.value > b.value
	)
	return scored_tiles
	

func get_tile_value(tile_pos:Vector2i)->int:
	var value = 0
	
	#increment by reachable targets
	for ability in host.get_abilities():
		if !ability.can_target_entities:
			continue
		
		for target in ability.get_valid_targets(tile_pos):
			if WorldManager.grid.threat_tiles.has(target.map_position):
				value += 5
			else:
				value += 10
	
	#increment by pathfinding to target
	if path_to_nearest_target.has(tile_pos):
		var host_map_pos = WorldManager.grid.local_to_map(host.position)
		value += 5 + host_map_pos.distance_to(tile_pos)
		
	#decrement by already threatened tiles
	if WorldManager.grid.threat_tiles.has(tile_pos):
		value -= 15
	return value


func _get_location_score(target_map_pos:Vector2i)->int: 
	var boundary_rect:Rect2i = WorldManager.grid.tiles_layer.get_used_rect()
	var distance_from_center = target_map_pos.distance_to(((boundary_rect.position + boundary_rect.size) / 2))
	return (distance_from_center / 2) * -1

func _on_host_death():
	if threat:
		WorldManager.grid.set_highlight(threat.tile,Grid.HIGHLIGHT_COLORS.NONE,Grid.HIGHLIGHT_LAYERS.THREAT)
