extends Ability
class_name AbilityMove

var path=[]
var initial_position
var target_position=null
var play_animation = false
signal move_target_set(map_position:Vector2i)

func _ready() -> void:
	super()
	has_ui = false
	ability_name = "move"
	ability_range = host.move_range
	is_enemy_obstacle = true
	effects = []
	is_action = false
	tile_exclude_flag = Grid.TILE_EXCLUDE_FLAGS.EXCLUDE_ALL_PROPS
	tile_exclude_self = true
	
func get_target_tiles(map_pos:Vector2i=host.map_position,_range:int=ability_range)->Array[Vector2i]:
	var navigatable_tiles:Array[Vector2i]= []
	var possible_tiles = WorldManager.level.grid.get_possible_tiles(host.team,tile_exclude_flag)
	var queued_tiles = [map_pos]
	
	var step = 0
	while !queued_tiles.is_empty():
		var pending_tiles = queued_tiles.duplicate()
		queued_tiles = []
		for direction in [Vector2i(-1,0),Vector2i(1,0),Vector2i(0,-1),Vector2i(0,1)]:
			for pending_tile in pending_tiles:
				var next_tile = pending_tile + direction
				if possible_tiles.has(next_tile) and !navigatable_tiles.has(next_tile):
					if host.map_position != next_tile and !WorldManager.level.grid.ally_entity_tiles.has(next_tile):
						navigatable_tiles.push_front(next_tile)
					queued_tiles.push_front(next_tile)
		step += 1
		if step == _range:
			break
	return navigatable_tiles

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("click") and state == STATE.TARGET_SELECT):
		target_position = WorldManager.level.grid.get_map_mouse_position()
		
#func _on_move_target_set(map_position:Vector2i)->void:
	#move_to_selected_tile(map_position)

func use(target_map_position:Vector2i, options:Dictionary={}):
	if !is_valid_target(target_map_position) and !options.get('absolute',false):
		stopped_targetting.emit()
		print("%s.%s[host.ability.use()]: no valid target found for pos %s"%[host.entity_name,ability_name,target_map_position])
		return
	
	initial_position = host.position
	if target_map_position == host.map_position:
		host.move_end.emit()
	else:
		target_position = target_map_position
		super(target_map_position)
		
func move_to_selected_tile(target_pos:Vector2i):
	var curr_tile = WorldManager.level.grid.local_to_map(host.position)
	path = WorldManager.level.grid.astar_grid.get_id_path(curr_tile, target_pos)
	if path.size() > 0:
		path.remove_at(0)
		
		path = path.filter(func(e):
			for ally in host.get_allies():
				if WorldManager.level.grid.local_to_map(ally.position) == e:
					return false
			return true
		)
	target_position = target_pos
		
	host.move_counter -= 1

	if Debug.show_move_path_highlight:
		show_path_highlight()


func _physics_process(delta: float) -> void:
	if target_position != null and path.size() > 0 and play_animation:
		move(delta)

func _play_animation(target_map_position:Vector2i):
	move_to_selected_tile(target_map_position)
	play_animation = true
	SfxManager.play("step-2")
	await host.move_end
	
func move(delta: float)->void:
	var curr_tile = WorldManager.level.grid.local_to_map(host.position)
	var next_local_pos = WorldManager.level.grid.map_to_local(path[0])
	var new_position = host.position.lerp(next_local_pos,0.4)

	host.position += (new_position - host.position) * delta * 45
	UIManager.ui.move_context_menu(host.global_position)

	var distance = host.position - new_position
	if abs(distance.x) < 0.1 and abs(distance.y) < 0.1:
		host.position = next_local_pos
	if host.position == next_local_pos:
		WorldManager.level.grid.set_map_cursor(curr_tile)
		path.remove_at(0)
	if path.size() == 0:
		target_position = null
		host.check_overlap(curr_tile)
		host.move_end.emit()
		
func show_path_highlight():
	for tile in path:
		WorldManager.level.grid.set_highlight(tile, Grid.HIGHLIGHT_COLORS.ORANGE,Grid.HIGHLIGHT_LAYERS.DEBUG)
	
func _on_used(ability:Ability):
	super(ability)
	if host.team == C.TEAM.PLAYER:
		WorldManager.level.entity_moved_history.push_front({"entity":host,"prev_map_position":initial_position})
		UIManager.ui.enable_undo_move_button()
