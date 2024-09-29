extends Entity
class_name Unit

func _ready() -> void:
	super()
	add_to_group(C.GROUPS.UNITS)
	#hit.connect(_on_hit)
	#death.connect(_on_death)
	WorldManager.turn_end.connect(_on_turn_end)
	WorldManager.turn_start.connect(_on_turn_start)
	
func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("action2"):
		pass
		#target_position = WorldManager.active_tilemap.get_local_mouse_position()
		#navigation_agent.target_position = global_position	
		
	
	elif event.is_action_pressed("click"):
		if team == C.TEAM.PLAYER:
			if( is_in_group(C.HOVERED_ENTITIES) and 
				(state == STATE.INACTIVE or state == STATE.SELECTED)
			): 
				show_move_range()
			elif(event.is_action_pressed("click") and state == STATE.MOVE_SELECTION):
				var mouse_pos = WorldManager.active_tilemap.get_local_mouse_position()
				var map_pos = WorldManager.active_tilemap.local_to_map(mouse_pos)
				var is_within_range = get_reachable_tiles(move_range).has(WorldManager.active_tilemap.get_map_mouse_position())
				if(is_within_range):
					move_to_selected_tile(map_pos)
				else:
					state = STATE.SELECTED
		
				remove_from_group(C.GROUPS.TARGETTING_ENTITY)
			elif(event.is_action_pressed("click") and state == STATE.TARGETTING):
				print("apply_ability")
		
func _process(delta: float) -> void:
	if target_position and path.size() > 0:
		move(delta)
	
func move(delta: float)->void:
	var curr_tile = WorldManager.active_tilemap.local_to_map(position)
	WorldManager.active_tilemap.set_highlight(curr_tile,CustomTileMapLayer.HIGHLIGHT_COLORS.BLUE)
	WorldManager.active_tilemap.set_highlight(path[0],CustomTileMapLayer.HIGHLIGHT_COLORS.RED)
	var next_local_pos = WorldManager.active_tilemap.map_to_local(path[0])
	position = position.lerp(next_local_pos,0.9)
	if position == next_local_pos:
		path.remove_at(0)
	
	if path.size() == 0:
		target_position = null
		check_overlap(curr_tile)
		move_end.emit()
	pass

func move_to_selected_tile(map_pos:Vector2):
		var local_pos = WorldManager.active_tilemap.map_to_local(map_pos) 
		var curr_tile = WorldManager.active_tilemap.local_to_map(position)
		target_position = map_pos
		path = WorldManager.active_tilemap.astar_grid.get_id_path(curr_tile, target_position)
		path.remove_at(0)
		print("path:", path)
		for tile in path:
			WorldManager.active_tilemap.set_highlight(tile, CustomTileMapLayer.HIGHLIGHT_COLORS.ORANGE)
	
		#state = STATE.MOVED
		state = STATE.SELECTED # test

func check_overlap(map_pos:Vector2i):
	for entity in get_tree().get_nodes_in_group(C.GROUPS.ENTITIES):
		if entity is Civilian:
			var civilian_tile_pos = WorldManager.active_tilemap.local_to_map(entity.position)
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
	WorldManager.active_tilemap.clear_all_highlights()
	var moveable_tile_positions = get_reachable_tiles(move_range)
	for pos in moveable_tile_positions:
		WorldManager.active_tilemap.set_highlight(pos)
		
func highlight_attack_range_tiles(attack_range):
	WorldManager.active_tilemap.clear_all_highlights()
	var moveable_tile_positions = get_reachable_tiles(attack_range)
	for pos in moveable_tile_positions:
		WorldManager.active_tilemap.set_highlight(pos,CustomTileMapLayer.HIGHLIGHT_COLORS.ORANGE)

func get_reachable_tiles(_range:int):
	var used_cells = WorldManager.active_tilemap.get_used_cells()
	var map_position = WorldManager.active_tilemap.local_to_map(position)
	
	var tiles = []
	for x in range(_range*-1, _range+1, 1):
		for y in range(_range*-1, _range+1, 1):
			var next_position = Vector2i(x+map_position.x, y+map_position.y)
			if(used_cells.has(next_position) and
			 WorldManager.active_tilemap.get_manhattan_distance(map_position,next_position) <= _range ):
				tiles.append(next_position)
	return tiles


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
		WorldManager.active_tilemap.clear_all_highlights()
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
