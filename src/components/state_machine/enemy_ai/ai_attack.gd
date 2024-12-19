extends State
class_name AIAttackState

var path_to_nearest_target
var target
var tile_labels:Array = []
var to_idle = false


func _ready() -> void:
	super()
	state_id = C.STATE.AI_ATTACK
	
func _on_configured():
	host.move_end.connect(_on_host_move_end)
	
func _enter_state(old_state, new_state):
	to_idle = false
	Util.sysprint("%s.ai_attack._enter_state"%[host.entity_name],"Entered attack state: %s"%[host.entity_name])
	var team_turn = WorldManager.team_turn
	if host.threat:
		await attack_target()
		if WorldManager.animation_counter != 0:
			print("Waiting on animation...")
			await WorldManager.animation_counter_cleared
			
	if team_turn == host.team:
		for l in tile_labels:
			l.queue_free()
		tile_labels = []
		
		var scored_tiles = analyze_tile_scores()
		scored_tiles = scored_tiles.filter(func (e): return e.value != 0)
		if scored_tiles.size() == 0:
			finalize_turn()
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
	
func find_threat():
	Util.sysprint("%s(host).%s(sm_node).find_threat()"%[host.entity_name,'ai_attack'],"start")
	var target_found = false
	for ability in host.get_abilities():
		if target_found:
			return
		if !ability.can_target_entities:
			return
		var valid_targets = ability.get_valid_targets()
		Util.sysprint("%s(host).%s(sm_node).find_threat()"%[host.entity_name,'ai_attack'],"ability:%s;valid_targets:%s"%[ability.ability_name,valid_targets])
		
		if valid_targets.size() > 0:
			target_found = true
			var valid_target = valid_targets[0]
			set_threat(valid_target.map_position, ability)
			
	if !target_found:
		host.clear_threat()
			

func attack_target():
	print("%s.%s[host.node.attack_target()]: -"%[host.entity_name,'ai_attack'])

	var targetted_entity = WorldManager.grid.get_entity_on_tile(host.threat.tile)
	
	await host.threat.ability.use(host.threat.tile)
	host.clear_threat()
	
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
	
func get_tile_value(tile_pos:Vector2i)->int:
	var value = 0
	
	#increment by reachable targets
	var threat_tiles = get_threat_tiles()
	for ability in host.get_abilities():
		if !ability.can_target_entities:
			continue
		for _target in ability.get_valid_targets(tile_pos):
			print(host.entity_name, " found valid target at ", _target.map_position, " ", _target.entity_name)
			#reduced score for an already targetted tile
			if threat_tiles.has(_target.map_position):
				value += 5
			else:
				value += 10
	
	#increment by pathfinding to target
	if path_to_nearest_target.has(tile_pos):
		var host_map_pos = WorldManager.grid.local_to_map(host.position)
		value += 5 + host_map_pos.distance_to(tile_pos)
		
	#decrement by already threatened tiles
	if threat_tiles.has(tile_pos):
		value -= 15
	return value

func set_threat(target_map_position:Vector2i,ability:Ability):
	var threat = {"tile":target_map_position, "ability":ability}
	Util.sysprint("%s.ai_attack.set_threat"%[host.entity_name],"ability:%s tile:%s"%[threat.ability.ability_name,str(threat.tile)])
	host.threat = threat
	host.threat_updated.emit()
	var targetted_entity = WorldManager.grid.get_entity_on_tile(host.threat.tile)


	
func get_threat_tiles():
	var threat_grid_tiles = WorldManager.get_team_group_threat_tiles(C.GROUPS_ENEMIES)
	if host.team == C.TEAM.ALLY:
		threat_grid_tiles = WorldManager.get_team_group_threat_tiles(C.GROUPS_ALLIES)
	return threat_grid_tiles

func _get_location_score(target_map_pos:Vector2i)->int: 
	var boundary_rect:Rect2i = WorldManager.grid.tiles_layer.get_used_rect()
	var distance_from_center = target_map_pos.distance_to(((boundary_rect.position + boundary_rect.size) / 2))
	return (distance_from_center / 2) * -1

func finalize_turn():
	print("finalize_turn: ", host.entity_name)
	await find_threat()
	await host.hide_all_details()
	to_idle = true
	host.turn_end.emit()
	
func _on_host_move_end():
	if !events_active:
		return
		
	finalize_turn()
