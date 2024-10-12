extends State
class_name AIAttackState

var possible_tiles = []
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
		attack_target()
		
	if team_turn == host.team:
		
		for l in tile_labels:
			l.queue_free()
		tile_labels = []
		
		analyze_tiles()
		if possible_tiles.size()  == 0:
			return
		
	
		if Debug.show_enemy_ai_tile_values:
			show_tile_values()
		
		host.get_ability("move").use(possible_tiles[0].position)
		#host.move_to_selected_tile(possible_tiles[0].position)

func show_tile_values():
	for t in possible_tiles:
		var l = Label.new()
		l.text = str(t.value)
		WorldManager.grid.prop_layer.add_child(l)
		l.position = WorldManager.grid.map_to_local(t.position) + Vector2(-8,-8)
		l.set("theme_override_font_sizes/font_size", 12)
		tile_labels.push_front(l)

func _transition():
	if to_idle:
		return C.STATE.AI_IDLE

		
func _on_host_move_end():
	highlight_target()
	host.hide_all_details()
	host.turn_end.emit()
	to_idle = true
	
func highlight_target():
	
	for ability in host.get_abilities():
		var target_count = 0
		if !ability.can_target_entities():
			return
		var reachable_tiles = host.get_reachable_tiles(ability.ability_range)
		for target in get_tree().get_nodes_in_group(C.GROUPS_TARGETS):
			var target_map_pos = WorldManager.grid.local_to_map(target.position)
			if reachable_tiles.has(target_map_pos):
				threat = {"tile":target_map_pos, "ability":ability, "target":target}
				WorldManager.grid.set_highlight(target_map_pos,Grid.HIGHLIGHT_COLORS.RED,Grid.HIGHLIGHT_LAYERS.THREAT)
				WorldManager.grid.threat_tiles.push_front(threat.tile)
				target_count += 1
				if ability.target_count == target_count:
					return
func attack_target():
	print("attack ")
	
	for threat_tile in [threat.tile]:
		for possible_target in get_tree().get_nodes_in_group(C.GROUPS_TARGETS):
			if is_instance_valid(possible_target):
				if WorldManager.grid.local_to_map(possible_target.position) == threat_tile:
					threat.ability.apply_effect(possible_target) 
	WorldManager.grid.set_highlight(threat.tile,Grid.HIGHLIGHT_COLORS.NONE,Grid.HIGHLIGHT_LAYERS.THREAT)
	
	threat = null
	
func analyze_tiles():
	possible_tiles = []
	var targets = get_tree().get_nodes_in_group(C.GROUPS_TARGETS)
	
	if targets.size() == 0:
		return
	
	targets.sort_custom(func(target1, target2):
		var distance1 = target1.position.distance_squared_to(host.position)
		var distance2 = target2.position.distance_squared_to(host.position)
		return distance1 <= distance2
	)
	for target in targets:
		if WorldManager.grid.threat_tiles.has(WorldManager.grid.local_to_map(target.position)):
			print("found threat tile ",target.entity_name)
			targets.erase(target)
			targets.push_back(target)
	
	var nearest = targets[0]
	if !nearest:
		return
	print(host.entity_name, " is targeting ", nearest.entity_name)
	
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
	
	for tile in get_moveable_tiles(host.move_range):
		possible_tiles.push_front({
			"position": tile,
			"value": get_tile_value(tile)
		})
		
	possible_tiles.sort_custom(
		func(a,b):
			return a.value > b.value
	)
	
#redundant remove when possible
func get_moveable_tiles(_range:int):
	var navigatable_tiles = []
	var _possible_tiles = WorldManager.grid.get_possible_tiles()
	var map_position = WorldManager.grid.local_to_map(host.position)
	
	var queued_tiles = [map_position]
	
	var step = 0
	while !queued_tiles.is_empty():
		var pending_tiles = queued_tiles.duplicate()
		queued_tiles = []
		for direction in [Vector2i(-1,0),Vector2i(1,0),Vector2i(0,-1),Vector2i(0,1)]:
			for pending_tile in pending_tiles:
				var next_tile = pending_tile + direction
				if _possible_tiles.has(next_tile):
					navigatable_tiles.push_front(next_tile)
					queued_tiles.push_front(next_tile)
		step += 1
		if step == _range:
			break
	return navigatable_tiles
	
func get_tile_value(tile_pos:Vector2i)->int:
	var value = 0
	
	for ability in host.get_abilities():
		for target in get_tree().get_nodes_in_group(C.GROUPS_TARGETS):
			var target_map_pos = WorldManager.grid.local_to_map(target.position)
			value += _get_attack_score(tile_pos,target_map_pos,ability.ability_range)
			
	if path_to_nearest_target.has(tile_pos):
		var host_map_pos = WorldManager.grid.local_to_map(host.position)
		value += 5 + host_map_pos.distance_to(tile_pos)
	else:
		value += _get_location_score(tile_pos)
		
	if WorldManager.grid.threat_tiles.has(tile_pos):
		value -= 15
	return value

func _get_attack_score(source_tile:Vector2i,target_map_pos:Vector2i, ability_range:int):
	var threat_factor := 1
	
	var distance_to_target = source_tile.distance_to(target_map_pos)
	if distance_to_target <= ability_range and distance_to_target != 0:
		if WorldManager.grid.threat_tiles.has(target_map_pos):
			threat_factor = 2
		return	roundi(10 / threat_factor)
	return 0

func _get_location_score(target_map_pos:Vector2i)->int: 
	var boundary_rect:Rect2i = WorldManager.grid.tiles_layer.get_used_rect()
	var distance_from_center = target_map_pos.distance_to(((boundary_rect.position + boundary_rect.size) / 2))
	return (distance_from_center / 2) * -1

func _on_host_death():
	if threat:
		WorldManager.grid.set_highlight(threat.tile,Grid.HIGHLIGHT_COLORS.NONE,Grid.HIGHLIGHT_LAYERS.THREAT)
