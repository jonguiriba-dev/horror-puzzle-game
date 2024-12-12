extends State
class_name AIAttackState

var path_to_nearest_target
var target
var threat
var tile_labels:Array = []
var to_idle = false
var grid_tiles

func _ready() -> void:
	super()
	state_id = C.STATE.AI_ATTACK
	
func _on_configured():
	host.move_end.connect(_on_host_move_end)
	host.death.connect(_on_host_death)
	host.knockback_animation_finished.connect(_on_knockback_animation_finished)
	
func _enter_state(old_state, new_state):
	grid_tiles = WorldManager.grid.enemy_threat_tiles
	if WorldManager.team_turn == C.TEAM.ALLY:
		grid_tiles = WorldManager.grid.ally_threat_tiles
		
	print("attack start")
	to_idle = false
	
	var team_turn = WorldManager.team_turn
	if threat:
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
	
func apply_threat():
	var target_found = false
	print("apply_threat: ",host.entity_name)
	for ability in host.get_abilities():
		if target_found:
			return
		if !ability.can_target_entities:
			return
			
		print("ability ",ability.ability_name)
		var valid_targets = ability.get_valid_targets()
		print("valid_targets ",valid_targets)
		
		if valid_targets.size() > 0:
			target_found = true
			var valid_target = valid_targets[0]
			set_threat(valid_target.map_position, ability)
	if !target_found:
		threat = null
			

func attack_target():
	print(">>> attack_target ")
	var targetted_entity = WorldManager.grid.get_entity_on_tile(threat.tile)
	var counter_attack_threat = check_counter_attack(targetted_entity)
	var counter_attack_group = [
		{
			"entity":host,
			"threat":threat,
		},
		{
			"entity":targetted_entity,
			"threat":counter_attack_threat,
		}
	]
	
	await threat.ability.use(threat.tile)
	if counter_attack_threat:
		await counter_attack_threat.ability.use(host.map_position)
		targetted_entity.set_meta("threat",null)
		WorldManager.clear_counter_attack_icons(counter_attack_group)
		
	clear_threat_tiles(host.map_position,threat.tile)
	threat = null

func check_counter_attack(targetted_entity:Entity):
	var targetted_entity_threat
	if (
		targetted_entity and 
		targetted_entity.team != host.team and 
		targetted_entity.has_meta("threat")
	):
		targetted_entity_threat = targetted_entity.get_meta("threat")
		if (
			targetted_entity_threat and 
			targetted_entity_threat.tile == host.map_position
		):
				return targetted_entity_threat
	return null

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
	
	for _target in targets:
		if grid_tiles.has(_target.map_position):
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
	for ability in host.get_abilities():
		if !ability.can_target_entities:
			continue
		
		for _target in ability.get_valid_targets(tile_pos):
			print("found valid target at ", _target.map_position)
			if grid_tiles.has(_target.map_position):
				value += 5
			else:
				value += 10
	
	#increment by pathfinding to target
	if path_to_nearest_target.has(tile_pos):
		var host_map_pos = WorldManager.grid.local_to_map(host.position)
		value += 5 + host_map_pos.distance_to(tile_pos)
		
	#decrement by already threatened tiles
	if grid_tiles.has(tile_pos):
		value -= 15
	return value

func set_threat(target_map_position:Vector2i,ability:Ability):
	threat = {"tile":target_map_position, "ability":ability}
	host.set_meta("threat",threat)
	add_threat_tiles(host.map_position,threat.tile)
	
	var targetted_entity = WorldManager.grid.get_entity_on_tile(threat.tile)
	var counter_attack_threat = check_counter_attack(targetted_entity)
	
	if counter_attack_threat:
		var counter_attack_group = [
			{
				"entity":host,
				"threat":threat,
			},
			{
				"entity":targetted_entity,
				"threat":counter_attack_threat,
			}
		]
				
		if !WorldManager.counter_attack_groups.has(counter_attack_group):
			WorldManager.counter_attack_groups.push_front(counter_attack_group)
			WorldManager.draw_counter_attack_groups()
func _get_location_score(target_map_pos:Vector2i)->int: 
	var boundary_rect:Rect2i = WorldManager.grid.tiles_layer.get_used_rect()
	var distance_from_center = target_map_pos.distance_to(((boundary_rect.position + boundary_rect.size) / 2))
	return (distance_from_center / 2) * -1

func clear_threat_tiles(source_map_pos:Vector2i,target_map_pos:Vector2i):
	var enemy_threat_tiles = threat.ability.get_enemy_threat_tiles(source_map_pos,target_map_pos)
	for threat_tile in enemy_threat_tiles:
		grid_tiles.erase(threat_tile)
	host.threat_updated.emit()

func add_threat_tiles(source_map_pos:Vector2i,target_map_pos:Vector2i):
	var enemy_threat_tiles = threat.ability.get_enemy_threat_tiles(source_map_pos,target_map_pos)
	for threat_tile in enemy_threat_tiles:
		grid_tiles.push_front(threat_tile)
	host.threat_updated.emit()
		
func _on_host_move_end():
	finalize_turn()
	
func finalize_turn():
	print("finalize_turn: ", host.entity_name)
	apply_threat()
	host.hide_all_details()
	host.turn_end.emit()
	to_idle = true


func _on_host_death():
	if threat:
		clear_threat_tiles(host.map_position,threat.tile)

func _on_knockback_animation_finished(distance:int, source_map_pos:Vector2i, prev_position:Vector2i):
	if threat:
		var direction = Util.get_direction(source_map_pos,host.map_position)
		clear_threat_tiles(prev_position,threat.tile)

		threat.tile += direction * distance 
		
		add_threat_tiles(host.map_position,threat.tile)
