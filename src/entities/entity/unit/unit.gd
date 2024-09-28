extends Entity
class_name Unit


enum STATE{
	INACTIVE,
	SELECTED,
	MOVE_SELECTION,
	MOVED,
	TARGETTING
}

var move_speed = 55
var move_range = 3
var can_move := false
var state := STATE.INACTIVE
var health = 1
var target_position=null
var path=null
signal hit(damage:int)
signal death

func _ready() -> void:
	super()
	add_to_group(C.GROUPS.UNITS)
	hit.connect(_on_hit)
	death.connect(_on_death)
	for ability in get_abilities():
		ability.connect("targetting",_on_ability_targetting)
		ability.connect("stopped_targetting",_on_ability_stopped_targetting)
		
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
				move_to_selected_tile()
			elif(event.is_action_pressed("click") and state == STATE.TARGETTING):
				print("apply_ability")
		
func _physics_process(delta: float) -> void:
	if target_position:
		move(delta)
	

func get_next_path_tile(next_path_pos:Vector2)->Vector2i:
	var next_tile = WorldManager.active_tilemap.local_to_map(position)
	var direction = global_position.direction_to(next_path_pos)
	
	print("XXX ",next_path_pos)
	if abs(direction).x > abs(direction.y):
		direction.y = 0
	else:
		direction.x = 0
	print("XXX direction ",direction)
		
	var rounded_direction = Vector2i(roundi(direction.x),roundi(direction.y))
	next_tile = WorldManager.active_tilemap.local_to_map(position) + rounded_direction
	
	if rounded_direction != Vector2i(0,0):
		print("direction",rounded_direction)
		print("curr_tile",WorldManager.active_tilemap.local_to_map(position) )
		print("-next_tile",next_tile )
	return next_tile

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
	pass

func check_overlap(map_pos:Vector2):
	for entity in get_tree().get_nodes_in_group(C.GROUPS.ENTITIES):
		if entity is Civilian:
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
	
func _on_ability_targetting(ability:Ability) -> void:
	highlight_attack_range_tiles(ability.ability_range)
	print("STATE 3")
	state = STATE.TARGETTING

func _on_ability_stopped_targetting(ability:Ability) -> void:
	WorldManager.active_tilemap.clear_all_highlights()
	state = STATE.SELECTED
	print("STATE 2")

func _on_hit(damage:int) -> void:
	health -= damage
	print("took damage", damage, " health ", health )
	if health <= 0:
		health = 0
		death.emit()
		print("death.emit")

func _on_death() -> void:
	print("death ",self)
	queue_free()
	
func show_move_range():
	highlight_moveable_tiles(move_range)
	UIManager.ui.set_context(self)
	state = STATE.MOVE_SELECTION
	add_to_group(C.GROUPS.TARGETTING_ENTITY)
	print("state: MOVE_SELECTION", state)

func move_to_selected_tile():
	var is_within_range = get_reachable_tiles(move_range).has(WorldManager.active_tilemap.get_map_mouse_position())
	if(is_within_range):
		var mouse_pos = WorldManager.active_tilemap.get_local_mouse_position()
		var map_pos = WorldManager.active_tilemap.local_to_map(mouse_pos)
		var local_pos = WorldManager.active_tilemap.map_to_local(map_pos) 
		
		#var target = get_tree().get_first_node_in_group(C.HOVERED_ENTITIES)
		#if target and target is Civilian:
			#WorldManager.active_tilemap.set_text_highlight("RESCUE", map_pos)
	
		var curr_tile = WorldManager.active_tilemap.local_to_map(position)
		target_position = map_pos
		path = WorldManager.active_tilemap.astar_grid.get_id_path(curr_tile, target_position)
		path.remove_at(0)
		print("path:", path)
		for tile in path:
			WorldManager.active_tilemap.set_highlight(tile, CustomTileMapLayer.HIGHLIGHT_COLORS.ORANGE)
	#
		#var global = WorldManager.active_tilemap.to_global(local_pos)
		#global -= Vector2(1,3) # wonder why this works best
		#move_to(global)
		#state = STATE.MOVED
		state = STATE.SELECTED # test
	else:
		state = STATE.SELECTED
		
	remove_from_group(C.GROUPS.TARGETTING_ENTITY)
		
	#WorldManager.active_tilemap.clear_all_highlights() #test
		
