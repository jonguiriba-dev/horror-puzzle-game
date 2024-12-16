extends Node

var grid: Grid
var team_turn:C.TEAM
var turn_order:=[C.TEAM.ALLY,  C.TEAM.PLAYER, C.TEAM.ENEMY]
var ai_turn_queue = []
var entity_moved_history:=[]
var input_enabled = false
var world:World
var current_dialogue:Dialogue
var entity_register_queue := []
var animation_counter := 0

signal turn_changed
signal turn_start(team: C.TEAM)
signal turn_end(team: C.TEAM)
signal viewport_ready
signal animation_counter_updated(val:int)
signal animation_counter_cleared

func _ready() -> void:
	get_viewport().ready.connect(_on_scenetree_ready)
	turn_start.connect(_on_turn_start)

func register_entity(entity:Entity):
	if !world:
		entity_register_queue.push_front(entity)
		return
		
	if entity.team == C.TEAM.ENEMY or entity.team == C.TEAM.ALLY:
		entity.turn_end.connect(_on_ai_unit_turn_end)
		
	if entity.team == C.TEAM.PLAYER or entity.team == C.TEAM.ALLY or entity.team == C.TEAM.CITIZEN:
		entity.set_orientation(world.orientation == C.ORIENTATION.VERTICAL) 

	if entity.team == C.TEAM.ENEMY:
		if world.orientation == C.ORIENTATION.VERTICAL:
			entity.set_orientation(world.orientation == C.ORIENTATION.HORIZONTAL)
		else:
			entity.set_orientation(world.orientation == C.ORIENTATION.VERTICAL)
			
	
	entity.threat_updated.connect(_on_entity_threat_updated)
	
func register_world(_world:World):
	world = _world
	
	for entity in entity_register_queue:
		register_entity(entity)
	
	entity_register_queue = []
	
func end_turn():
	turn_changed.emit()
	turn_end.emit(team_turn)
	turn_order.push_front(turn_order.pop_back())
	team_turn = turn_order[0]
	turn_start.emit(team_turn)
	
func _start_player_turn():
	for player_entity in get_tree().get_nodes_in_group(C.GROUPS_PLAYER_ENTITIES):
		player_entity.turn_start.emit()
	
func _start_ally_turn():
	ai_turn_queue = get_tree().get_nodes_in_group(C.GROUPS_ALLIES)
	if ai_turn_queue.size() > 0:
		var entity = ai_turn_queue.pop_front()
		entity.turn_start.emit()
		
func _start_enemy_turn():
	ai_turn_queue = get_tree().get_nodes_in_group(C.GROUPS_ENEMIES)
	if ai_turn_queue.size() > 0:
		var entity = ai_turn_queue.pop_front()
		entity.turn_start.emit()
		
func game_start():
	if !UIManager.ui:
		return
	WorldManager.clear_entity_moved_history()
	if Debug.play_game_start_sequence:
		await UIManager.play_game_start_sequence()
	
	if Debug.play_game_start_dialogue:
		for dialogue in world.dialogues:
			if dialogue.trigger == C.DIALOGUE_TRIGGER.ON_START:
				current_dialogue = dialogue
				current_dialogue.input_waiting.connect(_on_dialogue_input_waiting)
				await current_dialogue.play(get_tree().get_nodes_in_group(C.GROUPS_ENTITIES))
	current_dialogue = null
	
	team_turn = turn_order[0]
	turn_start.emit(team_turn)

var input_waiting_on_ability = false
var input_waiting_on_dialogue = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") :
		print("World Manager click ")
		if input_waiting_on_dialogue:
			current_dialogue.input_recieved.emit()
			input_waiting_on_dialogue = false
		
		if UIManager.ability_hovered:
			UIManager.ability_hovered.target_select.emit()	
			
		if UIManager.ui.context_menu.visible:
			UIManager.ui.context_menu.hide()	
			
		if !input_enabled:
			return
			
		if input_waiting_on_ability:
			return
			
		var mouse_map_position = WorldManager.grid.local_to_map(WorldManager.grid.prop_layer.get_local_mouse_position())
		var targetting_ability := get_tree().get_first_node_in_group(C.GROUPS_TARGETTING_ABILITY) as Ability
		var hovered_entity = get_tree().get_first_node_in_group(C.GROUPS_HOVERED_ENTITIES)
		print("hovered_entity ",hovered_entity)
		
		if targetting_ability and !input_waiting_on_ability:
			input_waiting_on_ability = true
			targetting_ability.stopped_targetting.connect(func():
				input_waiting_on_ability = false
			,ConnectFlags.CONNECT_ONE_SHOT)
			targetting_ability.use(mouse_map_position)
			if !targetting_ability.is_valid_target(mouse_map_position):
				grid.tile_selected.emit(mouse_map_position)
				if is_instance_valid(hovered_entity):
					hovered_entity.selected.emit()
					
		elif is_instance_valid(hovered_entity):
			hovered_entity.selected.emit()
			grid.tile_selected.emit(mouse_map_position)
		else:
			grid.tile_selected.emit(mouse_map_position)
			UIManager.ui.clear_context()
			
		print("*Tile Position: ",mouse_map_position)

func _on_dialogue_input_waiting():
	input_waiting_on_dialogue = true

func check_player_victory():
	if get_tree().get_nodes_in_group(C.GROUPS_ENEMIES).size() == 0:
		UIManager.show_victory_overlay()

func clear_entity_moved_history():
	entity_moved_history.clear()
	if UIManager.ui:
		UIManager.ui.disable_undo_move_button()

func increment_animation_counter(val: int):
	animation_counter += val
	animation_counter_updated.emit(animation_counter)
	if animation_counter == 0:
		animation_counter_cleared.emit()

var order_labels = []
func show_turn_order():
	print("show_turn_order")
	var i=1
	for enemy in get_tree().get_nodes_in_group(C.GROUPS_ENEMIES):
		var label = Label.new()
		enemy.add_child(label)
		label.position = Vector2(8,-32)
		label.text = str(i)
		label.set('theme_override_colors/font_color',Color('#cc2f44'))
		label.set('theme_override_colors/font_outline_color',Color('#121212'))
		label.set('theme_override_constants/outline_size',12)
		label.set('theme_override_font_sizes/font_size',10)
		i+=1
		order_labels.push_front(label)

	i=1
	for enemy in get_tree().get_nodes_in_group(C.GROUPS_ALLIES):
		var label = Label.new()
		enemy.add_child(label)
		label.position = Vector2(8,-32)
		label.text = str(i)
		label.set('theme_override_colors/font_color',Color('#2fb7cc'))
		label.set('theme_override_colors/font_outline_color',Color('#121212'))
		label.set('theme_override_constants/outline_size',12)
		label.set('theme_override_font_sizes/font_size',10)
		i+=1
		order_labels.push_front(label)
func hide_turn_order():
	print("hide_turn_order")
	for i in range(order_labels.size()):
		order_labels.pop_front().queue_free()

func _on_scenetree_ready():
	if UIManager.ui:
		UIManager.ui.undo_move_pressed.connect(_on_undo_move_pressed)
		UIManager.ui.end_turn_pressed.connect(_on_end_turn_pressed)
		UIManager.ui.turn_order_pressed.connect(_on_turn_order_pressed)
	viewport_ready.emit()
	await game_start()
	_start_player_turn()

func _on_end_turn_pressed():
	if team_turn == C.TEAM.PLAYER:
		UIManager.ui.end_turn.disabled = true
		end_turn()

func _on_turn_order_pressed():
	if team_turn == C.TEAM.PLAYER:
		print("TURN ORDER")
		if order_labels.size()>0:
			hide_turn_order()
		else:
			show_turn_order()
	
func _on_turn_start(turn:C.TEAM):
	await UIManager.ui.present_turn_start_overlay(C.TEAM.keys()[turn])
	
	if turn == C.TEAM.ENEMY:
		_start_enemy_turn()
	elif turn == C.TEAM.PLAYER:
		_start_player_turn()
	elif turn == C.TEAM.ALLY:
		_start_ally_turn()

			
func _on_ai_unit_turn_end():
	if ai_turn_queue.size() == 0 and (team_turn == C.TEAM.ENEMY or team_turn == C.TEAM.ALLY):
		_on_all_ai_done()
		return
		
	var ai_entity = ai_turn_queue.pop_front()
	print("my turn: ", ai_entity.entity_name)
	if is_instance_valid(ai_entity):
		ai_entity.turn_start.emit()

func _on_all_ai_done():
	UIManager.ui.end_turn.disabled = false
	end_turn()
	input_enabled = true


func _on_enemy_unit_turn_start(entity:Entity):
	entity.show_detail("rescue")

func _on_undo_move_pressed():
	if entity_moved_history.size() > 0:
		var history = entity_moved_history.pop_front() as Dictionary
		history["entity"].undo_move(history["prev_map_position"])
		
		if entity_moved_history.size() == 0:
			WorldManager.clear_entity_moved_history()

func _on_entity_threat_updated():
	grid.highlight_threat_tiles(
		get_team_group_threat_tiles(C.GROUPS_ENEMIES),
		get_team_group_threat_tiles(C.GROUPS_ALLIES)
	)

func get_team_group_threat_tiles(group:String):
	var tiles = []
	for entity in get_tree().get_nodes_in_group(group):
		if !entity.threat: continue
		var threat_tiles = entity.threat.ability.get_threat_tiles(entity.map_position,entity.threat.tile)
		for threat_tile in threat_tiles:
			tiles.push_front(threat_tile)
	return tiles
