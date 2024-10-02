extends Entity
class_name Unit

func _ready() -> void:
	super()
	add_to_group(C.GROUPS.UNITS)
	
	if team == C.TEAM.ENEMY:
		add_to_group(C.GROUPS.ENEMIES)
		
	#hit.connect(_on_hit)
	#death.connect(_on_death)
	WorldManager.turn_end.connect(_on_turn_end)
	WorldManager.turn_start.connect(_on_turn_start)
	
func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("action2"):
		pass
		#target_position = WorldManager.grid.get_local_mouse_position()
		#navigation_agent.target_position = global_position	
	
	elif event.is_action_pressed("click"):
		if team == C.TEAM.PLAYER:
			if( is_in_group(C.HOVERED_ENTITIES) and 
				(state == STATE.INACTIVE or state == STATE.SELECTED)
			): 
				show_move_range()
			elif(event.is_action_pressed("click") and state == STATE.MOVE_SELECTION):
				var mouse_map_pos = WorldManager.grid.get_map_mouse_position()
				var is_within_range = get_moveable_tiles(move_range).has(WorldManager.grid.get_map_mouse_position())
				if(is_within_range):
					move_to_selected_tile(mouse_map_pos)
				else:
					state = STATE.SELECTED
		
				remove_from_group(C.GROUPS.TARGETTING_ENTITY)
			elif(event.is_action_pressed("click") and state == STATE.TARGETTING):
				print("apply_ability")
		
func _physics_process(delta: float) -> void:
	if target_position != null and path.size() > 0:
		move(delta)
	
func move(delta: float)->void:
	var curr_tile = WorldManager.grid.local_to_map(position)
	var next_local_pos = WorldManager.grid.map_to_local(path[0])
	var new_position = position.lerp(next_local_pos,0.4)
	

	## Update position based on delta for smooth movement
	position += (new_position - position) * delta * 45
	#position = new_position
	print(">> ",position," ",next_local_pos)
	var distance = position - new_position
	if abs(distance.x) < 0.1 and abs(distance.y) < 0.1:
		position = next_local_pos
	if position == next_local_pos:
		path.remove_at(0)
	if path.size() == 0:
		target_position = null
		check_overlap(curr_tile)
		move_end.emit()

func move_to_selected_tile(target_pos:Vector2):
		var curr_tile = WorldManager.grid.local_to_map(position)
		path = WorldManager.grid.astar_grid.get_id_path(curr_tile, target_pos)
		path.remove_at(0)
		target_position = target_pos
		
		for tile in path:
			WorldManager.grid.set_highlight(tile, Grid.HIGHLIGHT_COLORS.ORANGE)
	
		#state = STATE.MOVED
		state = STATE.SELECTED # test

func check_overlap(map_pos:Vector2i):
	for entity in get_tree().get_nodes_in_group(C.GROUPS.ENTITIES):
		if entity is Civilian:
			var civilian_tile_pos = WorldManager.grid.local_to_map(entity.position)
			if civilian_tile_pos == map_pos:
				entity.rescued.emit()
	
func get_abilities()->Array[Ability]:
	var abilities:Array[Ability]= []
	for child in get_children():
		if child.name.contains("Ability_"):
			var ability = child as Ability
			abilities.append(ability)
		
	return abilities

func highlight_moveable_tiles(move_range):
	WorldManager.grid.clear_all_highlights()
	var moveable_tile_positions = get_moveable_tiles(move_range)
	print("moveable_tile_positions:",moveable_tile_positions)
	for pos in moveable_tile_positions:
		WorldManager.grid.set_highlight(pos, Grid.HIGHLIGHT_COLORS.BLUE)
		
func highlight_attack_range_tiles(attack_range):
	WorldManager.grid.clear_all_highlights()
	var moveable_tile_positions = get_reachable_tiles(attack_range)
	for pos in moveable_tile_positions:
		WorldManager.grid.set_highlight(pos,Grid.HIGHLIGHT_COLORS.ORANGE)

func get_reachable_tiles(_range:int):
	var possible_tiles = WorldManager.grid.get_possible_tiles()
	var map_position = WorldManager.grid.local_to_map(position)
	
	var tiles = []
	for x in range(_range*-1, _range+1, 1):
		for y in range(_range*-1, _range+1, 1):
			var next_position = Vector2i(x+map_position.x, y+map_position.y)
			if(possible_tiles.has(next_position) and
			 WorldManager.grid.get_manhattan_distance(map_position,next_position) <= _range ):
				tiles.append(next_position)
	return tiles

func get_moveable_tiles(_range:int):
	var navigatable_tiles = []
	var possible_tiles = WorldManager.grid.get_possible_tiles()
	var map_position = WorldManager.grid.local_to_map(position)
	
	var queued_tiles = [map_position]
	
	var step = 0
	while !queued_tiles.is_empty():
		var pending_tiles = queued_tiles.duplicate()
		queued_tiles = []
		for direction in [Vector2i(-1,0),Vector2i(1,0),Vector2i(0,-1),Vector2i(0,1)]:
			for pending_tile in pending_tiles:
				var next_tile = pending_tile + direction
				if possible_tiles.has(next_tile):
					navigatable_tiles.push_front(next_tile)
					queued_tiles.push_front(next_tile)
		step += 1
		if step == _range:
			break
	return navigatable_tiles

func _on_mouse_entered() -> void:
	add_to_group(C.HOVERED_ENTITIES)
	
func _on_mouse_exited() -> void:
	remove_from_group(C.HOVERED_ENTITIES)

	
func show_move_range():
	highlight_moveable_tiles(move_range)
	UIManager.ui.set_context(self)
	add_to_group(C.GROUPS.TARGETTING_ENTITY)
	state = STATE.MOVE_SELECTION
	print("state: MOVE_SELECTION")

func _on_turn_start(team_turn:C.TEAM):
	print("team_turn: ", team_turn)
	if team_turn == team:
		print("start turn ", entity_name)
		state = STATE.INACTIVE
		
		if team == C.TEAM.PLAYER:
			sprite.modulate = Color("ffffff")
	
func _on_turn_end(team_turn: C.TEAM):
	print("team_turn: ", team_turn)
	if team_turn == team :
		WorldManager.grid.clear_all_highlights()
		state = STATE.DONE
		print("end turn: ", entity_name)
	
		if team == C.TEAM.PLAYER:
			sprite.modulate = Color("626262")
			

#func _on_hit(damage:int) -> void:
	#health -= damage
	#print("took damage", damage, " health ", health )
	#if health <= 0:
		#health = 0
		#death.emit()
		#print("death.emit")
#func _on_death() -> void:
	#print("death ",self)
	#queue_free()
