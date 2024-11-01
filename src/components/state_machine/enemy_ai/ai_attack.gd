extends State
class_name AIAttackState

var path_to_nearest_target
var target
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
	var target_found = false
	print("apply_threat: ",host.entity_name)
	for ability in host.get_abilities():
		if !ability.can_target_entities:
			return
		print("ability ",ability.ability_name)
		var valid_targets = ability.get_valid_targets()
		print("valid_targets ",valid_targets)
		
		if target_found:
			return
		
		
		for valid_target in valid_targets:
			if target_found:
				return
			threat = {"tile":valid_target.map_position, "ability":ability, "target":valid_target}
			WorldManager.grid.set_highlight(threat.tile,Grid.HIGHLIGHT_COLORS.RED,Grid.HIGHLIGHT_LAYERS.THREAT)
			WorldManager.grid.threat_tiles.push_front(threat.tile)
			target_found = true
			
		#for target in get_tree().get_nodes_in_group(C.GROUPS_EN):
			#if reachable_tiles.has(target.map_position):
				#print("reach")
				#threat = {"tile":target.map_position, "ability":ability, "target":target}
				#WorldManager.grid.set_highlight(target.map_position,Grid.HIGHLIGHT_COLORS.RED,Grid.HIGHLIGHT_LAYERS.THREAT)
				#WorldManager.grid.threat_tiles.push_front(threat.tile)
				#target_count += 1
				#if ability.target_count == target_count:
					#return
func attack_target():
	print(">>> attack_target ")
	await threat.ability.use(threat.tile) 
	WorldManager.grid.set_highlight(threat.tile,Grid.HIGHLIGHT_COLORS.NONE,Grid.HIGHLIGHT_LAYERS.THREAT)
	threat = null
	
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
	print("analyze_tile_scores ",get_tree().get_nodes_in_group(C.GROUPS_ENTITIES))

	if targets.size() == 0:
		return scored_tiles
	
	targets.map(func (e:Node):
		var distance = Util.get_pathfinding_distance(e.map_position,host.map_position)
		e.set_meta("distance_to_host",distance)
	)
	
	targets.sort_custom(func(target1, target2):
		return target1.get_meta("distance_to_host") <= target2.get_meta("distance_to_host") 
	)
	
	for _target in targets:
		if WorldManager.grid.threat_tiles.has(_target.map_position):
			targets.erase(_target)
			targets.push_back(_target)
		
	var nearest = targets[0]
	if !nearest:
		return scored_tiles
	
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
	
	var moveable_tiles = host.get_ability("move").get_target_tiles()
	for tile in moveable_tiles:
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
		
		for _target in ability.get_valid_targets(tile_pos):
			print("found valid target at ", _target.map_position)
			if WorldManager.grid.threat_tiles.has(_target.map_position):
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
