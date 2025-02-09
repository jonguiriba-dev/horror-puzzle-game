extends Control
class_name World

@export var dialogues:Array[Dialogue]=[]
@export var orientation:=C.ORIENTATION.HORIZONTAL
@export var spawn_config:LevelSpawnConfig
@export var rewards_config:LevelRewardsConfig

@onready var grid: Grid = $Grid

var team_turn:C.TEAM
var turn_order:=[C.TEAM.ALLY,  C.TEAM.PLAYER]
var ai_turn_queue = []
var entity_moved_history:=[]
var input_enabled = false
var world:World
var current_dialogue:Dialogue
var entity_register_queue := []
var animation_counter := 0
var selected_entity:Entity
var strategy := C.STRATEGIES.NEAREST
var strategy_changed := false
var starting_position := C.DIRECTION.NORTH
var enemy_count := 0
var neutral_count := 0
var current_ai_entity_in_action: Entity
var level_gold = 10
var level_exp = 0
var loaded_data

signal turn_changed
signal turn_start(team: C.TEAM)
signal turn_end(team: C.TEAM)
signal viewport_ready
signal animation_counter_updated(val:int)
signal animation_counter_cleared

func _enter_tree() -> void:
	WorldManager.register_level(self)
	
func _ready() -> void:
	turn_start.connect(_on_turn_start)
	
	_on_scenetree_ready()
	
func _on_scenetree_ready():
	var ui_node = UIManager.set_ui(UIManager.UI_TYPE.LEVEL)
	if ui_node:
		UIManager.ui.undo_move_pressed.connect(_on_undo_move_pressed)
		UIManager.ui.end_turn_pressed.connect(_on_end_turn_pressed)
		UIManager.ui.turn_order_pressed.connect(_on_turn_order_pressed)
		UIManager.ui.strategy_changed.connect(func ():
			strategy_changed = true
		)
	
	viewport_ready.emit()
	await game_start()
	#_start_player_turn()

func end_turn():
	UIManager.ui.clear_context()
	turn_changed.emit()
	turn_end.emit(team_turn)
	turn_order.push_front(turn_order.pop_back())
	team_turn = turn_order[0]
	turn_start.emit(team_turn)
	input_waiting_on_ability = false
	
func _start_player_turn():
	Util.sysprint("_start_player_turn","start")
	input_enabled = true
	for player_entity in get_tree().get_nodes_in_group(C.GROUPS_PLAYER_ENTITIES):
		player_entity.turn_start.emit()
	
func _start_ally_turn():
	Util.sysprint("_start_ally_turn","start")
	
	if strategy_changed:
		var random_ally = get_tree().get_nodes_in_group(C.GROUPS_ALLIES).pick_random()
		DialogueManager.speak(random_ally.global_position,
		DialogueManager.get_scenario_text("to_strategy_%s"%[C.STRATEGIES.keys()[strategy].to_lower()])
		,1)
		await AnimationManager.squeeze(random_ally)

		strategy_changed = false
		
	ai_turn_queue = get_tree().get_nodes_in_group(C.GROUPS_ALLIES)
	if ai_turn_queue.size() > 0:
		var entity = ai_turn_queue.pop_front()
		entity.turn_start.emit()
		Util.sysprint("WorldManager._start_ally_turn","entity turn start: %s"%[entity.data.entity_name])
	else:
		end_turn()
		
func _start_enemy_turn():
	Util.sysprint("_start_enemy_turn","start")
	ai_turn_queue = get_tree().get_nodes_in_group(C.GROUPS_ENEMIES)
	if ai_turn_queue.size() > 0:
		var entity = ai_turn_queue.pop_front()
		entity.turn_start.emit()
		Util.sysprint("WorldManager._start_enemy_turn","entity turn start: %s"%[entity.data.entity_name])
	else:
		end_turn()
		
func _start_ai_turn():
	Util.sysprint("_start_ai_turn","start")
	
	if strategy_changed:
		var random_ally = get_tree().get_nodes_in_group(C.GROUPS_ALLIES).pick_random()
		DialogueManager.speak(random_ally.global_position,
		DialogueManager.get_scenario_text("to_strategy_%s"%[C.STRATEGIES.keys()[strategy].to_lower()])
		,1)
		await AnimationManager.squeeze(random_ally)

		strategy_changed = false
		
	ai_turn_queue = get_tree().get_nodes_in_group(C.GROUPS_ALLIES)
	ai_turn_queue.append_array(get_tree().get_nodes_in_group(C.GROUPS_ENEMIES))
	
	ai_turn_queue.shuffle() #temp
	
	if ai_turn_queue.size() > 0:
		var entity = ai_turn_queue.pop_front()
		entity.turn_start.emit()
		Util.sysprint("WorldManager._start_ai_turn","entity turn start: %s"%[entity.data.entity_name])
	else:
		end_turn()
		
func game_start():
	Util.sysprint("Level","game start!")
	selected_entity = null
	if SaveManager.get_loaded("level","entities"):
		await load_units()
	else:
		await spawn_units()
	await register_entities()
	if !UIManager.ui:
		Util.sysprint("game_start","UIManager.ui not found")
		return
	clear_entity_moved_history()
	UIManager.ui.turn_start_overlay.hide()

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
	turn_order = SaveManager.get_loaded("level","turn_order",turn_order)
	team_turn = SaveManager.get_loaded("level","team_turn",team_turn)

		
	turn_start.emit(team_turn)
	
func load_units():
	for entity in SaveManager.get_loaded("level","entities",[]):
		var loaded_entity = EntityManager.load_entity(entity)
		loaded_entity.set_meta("recently_loaded",true)

		EntityManager.spawn_entity(
			loaded_entity.position,
			loaded_entity
		)
		
func spawn_units():
	var player_spawn_tiles = WorldManager.level.grid.get_team_position_tiles(Grid.TEAM_POSITION_LAYER_FILTERS.PLAYER)
	player_spawn_tiles.shuffle()
	for player_unit in PlayerManager.units:
		EntityManager.spawn_entity(
			WorldManager.level.grid.map_to_local(player_spawn_tiles.pop_front()),
			player_unit
		)
		player_unit.refresh_move_and_action_counters()
		
	var spawn_record = {}
	var enemy_spawn_tiles = WorldManager.level.grid.get_team_position_tiles(Grid.TEAM_POSITION_LAYER_FILTERS.ENEMY)
	enemy_spawn_tiles.shuffle()
	while(enemy_count < spawn_config.max_enemies):
		for enemy_spawn in spawn_config.enemy_spawn_pool:
			if enemy_count >= spawn_config.max_enemies:
				break
			var rng = randf_range(0.1,1.0)
			if enemy_spawn.spawn_rate > rng:
				EntityManager.spawn_entity(
					WorldManager.level.grid.map_to_local(enemy_spawn_tiles.pop_front()), 
					EntityManager.create_entity(enemy_spawn.entity_preset)
				)
				var current_spawn_count = spawn_record.get_or_add(enemy_spawn.entity_preset,0)
				if current_spawn_count < enemy_spawn.max_number:
					spawn_record[enemy_spawn.entity_preset] += 1
					enemy_count += 1
	
	var neutral_spawn_tiles = WorldManager.level.grid.get_team_position_tiles(Grid.TEAM_POSITION_LAYER_FILTERS.NEUTRAL)
	neutral_spawn_tiles.shuffle()
	while(neutral_count < spawn_config.max_neutrals):
		for neutral_spawn in spawn_config.neutral_spawn_pool:
			var rng = randf_range(0.1,1.0)
			if neutral_spawn.spawn_rate > rng:
				EntityManager.spawn_entity(
					WorldManager.level.grid.map_to_local(neutral_spawn_tiles.pop_front()), 
					EntityManager.create_entity(neutral_spawn.entity_preset)
				)
				neutral_count += 1
	
var input_waiting_on_ability = false
var input_waiting_on_dialogue = false


func _on_dialogue_input_waiting():
	input_waiting_on_dialogue = true

func check_player_victory():
	if get_tree().get_nodes_in_group(C.GROUPS_ENEMIES).size() == 0:
		UIManager.show_victory_overlay()
		var player_entities = get_tree().get_nodes_in_group(C.GROUPS_PLAYER_ENTITIES)
		player_entities.append_array(get_tree().get_nodes_in_group(C.GROUPS_ALLIES)) 
		
		UIManager.ui.overlay_clicked.connect(func():
			UIManager.hide_victory_overlay()
			
			give_player_rewards()
			
			var reward_abilities = get_reward_abilities()
			UIManager.show_reward_overlay(reward_abilities)
			UIManager.reward_card_selected.connect(func(reward_card):
				var ability_prop = reward_card.get_meta("data")
				var entity = reward_card.get_meta("target_entity")
				PlayerManager.add_entity_ability(entity,ability_prop)
				UIManager.hide_reward_overlay()
				SceneManager.change_scene(SceneManager.SCENE_MAP)
				for player_entity in player_entities:
					player_entity.get_parent().remove_child(player_entity)
				WorldManager.level = null
				WorldManager.level_complete.emit()
				UIManager.clear_ui()
			, CONNECT_ONE_SHOT)
			
		, CONNECT_ONE_SHOT)	

func give_player_rewards():
	PlayerManager.add_gold(level_gold)
	
func get_reward_abilities():
	var abilities :Array[AbilityProp]= []
	while abilities.size() < rewards_config.max_rewards:
		for ability_reward in rewards_config.ability_reward_pool:
			if abilities.size() >= rewards_config.max_rewards:
				break
			var rng = randf_range(0.1,1.0)
			if rng < ability_reward.chance:
				abilities.push_front(ability_reward.value)
	print("get_reward_abilities",abilities)
	return abilities
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
	for i in range(order_labels.size()):
		order_labels.pop_front().queue_free()

func get_team_group_threat_tiles(group:String):
	var tiles = []
	for entity in get_tree().get_nodes_in_group(group):
		entity = entity as Entity
		if !entity.threat: continue
		var threat_tiles = (
			entity.threat.ability.get_threat_tiles(
				entity.map_position,
				entity.threat.tile
			)
		)
		for threat_tile in threat_tiles:
			tiles.push_front(threat_tile)
	return tiles

func get_world_bounds():
	return grid.tiles_layer.get_used_rect()

func register_entities():
	print("entity_register_queue",entity_register_queue)
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
		register_entity(entity)
	entity_register_queue = []

func register_entity(entity:Entity):
	if !grid:
		entity_register_queue.push_front(entity)
		return
		
	if entity.data.team == C.TEAM.ENEMY or entity.data.team == C.TEAM.ALLY:
		entity.turn_end.connect(_on_ai_unit_turn_end)
		
	if entity.data.team == C.TEAM.PLAYER or entity.data.team == C.TEAM.ALLY or entity.data.team == C.TEAM.CITIZEN:
		entity.set_orientation(orientation == C.ORIENTATION.VERTICAL) 

	if entity.data.team == C.TEAM.ENEMY:
		if orientation == C.ORIENTATION.VERTICAL:
			entity.set_orientation(orientation == C.ORIENTATION.VERTICAL)
			#entity.set_orientation(orientation == C.ORIENTATION.HORIZONTAL)
		else:
			entity.set_orientation(orientation == C.ORIENTATION.HORIZONTAL)
			#entity.set_orientation(orientation == C.ORIENTATION.VERTICAL)
	
	entity.threat_updated.connect(_on_entity_threat_updated)
	entity.turn_end.connect(_on_unit_turn_end)
	entity.sprite.speed_scale = SystemManager.idle_animation_speed
	entity.position = grid.map_to_local(entity.map_position)
	
func _on_end_turn_pressed():
	Util.sysprint("Level:_on_end_turn_pressed","start")
	if team_turn == C.TEAM.PLAYER:
		UIManager.ui.end_turn.disabled = true
		end_turn()

func _on_turn_order_pressed():
	if team_turn == C.TEAM.PLAYER:
		if order_labels.size()>0:
			hide_turn_order()
		else:
			show_turn_order()
	
func _on_turn_start(turn:C.TEAM):
	SaveManager.save_data("level",to_save_data())
	SaveManager.save_game()
	
	if Debug.show_turn_card:
		await UIManager.ui.present_turn_start_overlay(C.TEAM.keys()[turn])
	Util.sysprint("WorldManager._on_turn_start","turn start: %s"%[C.TEAM.keys()[turn]])
	if turn == C.TEAM.ENEMY:
		_start_ai_turn()
		#_start_enemy_turn()
	elif turn == C.TEAM.PLAYER:
		_start_player_turn()
	elif turn == C.TEAM.ALLY:
		_start_ai_turn()

		
func _on_ai_unit_turn_end():
	Util.sysprint("Level:_on_ai_unit_turn_end","ai_turn_queue:%s"%[ai_turn_queue.size()])
	if is_instance_valid(current_ai_entity_in_action):
		current_ai_entity_in_action.clear_sprite_material()
	current_ai_entity_in_action = null
	if (
		ai_turn_queue.size() == 0 
		and (team_turn == C.TEAM.ENEMY or team_turn == C.TEAM.ALLY)
	):
		_on_all_ai_done()
	else:
		#keep looping to find a valid ai_entity that could take its turn
		while ai_turn_queue.size() > 0:
			var ai_entity = ai_turn_queue.pop_front()
			await Util.wait(0.1)
			if is_instance_valid(ai_entity):
				print("my turn: ", ai_entity.data.entity_name)
				current_ai_entity_in_action = ai_entity
				if Debug.highlight_entity_in_action:
					current_ai_entity_in_action.sprite.material = preload("res://src/shaders/outline/selected_highlight_material.tres")
				ai_entity.turn_start.emit()
				break

func _on_unit_turn_end():
	SaveManager.save_data("level",to_save_data())
	SaveManager.save_game()

func _on_all_ai_done():
	UIManager.ui.end_turn.disabled = false
	end_turn()


func _on_enemy_unit_turn_start(entity:Entity):
	entity.show_detail("rescue")

func _on_undo_move_pressed():
	if entity_moved_history.size() > 0:
		var history = entity_moved_history.pop_front() as Dictionary
		history["entity"].undo_move(history["prev_map_position"])
		
		if entity_moved_history.size() == 0:
			clear_entity_moved_history()

func _on_entity_threat_updated():
	grid.highlight_threat_tiles(
		get_team_group_threat_tiles(C.GROUPS_ENEMIES),
		get_team_group_threat_tiles(C.GROUPS_ALLIES)
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") :
		Util.sysprint("Level._unhandled_input()","click")
		var mouse_map_position = grid.local_to_map(grid.prop_layer.get_local_mouse_position())
		var targetting_ability := get_tree().get_first_node_in_group(C.GROUPS_TARGETTING_ABILITY) as Ability
		var hovered_entity = get_tree().get_first_node_in_group(C.GROUPS_HOVERED_ENTITIES)
		if hovered_entity:
			Util.sysprint("WorldManager._unhandled_input()","entity hovered: %s"%[hovered_entity.data.entity_name])
		
		if targetting_ability:
			Util.sysprint("WorldManager._unhandled_input()","targetting ability: %s"%[targetting_ability.ability_name])
		
		if input_waiting_on_ability:
			print(">input_waiting_on_ability return")
			return
		if !input_enabled:
			return
			
		if selected_entity and !targetting_ability:
			print(">selected_entity and !targetting_ability")
			selected_entity.clear_sprite_material()
			selected_entity = null
		
		if input_waiting_on_dialogue:
			current_dialogue.input_recieved.emit()
			input_waiting_on_dialogue = false
		
		if UIManager.ability_hovered:
			UIManager.ability_hovered.target_select.emit()	
			
		if targetting_ability and !input_waiting_on_ability:		
			print(">targetting_ability and !input_waiting_on_ability")
			if selected_entity and targetting_ability.ability_name != "move":
				selected_entity.clear_sprite_material()
				selected_entity = null
			input_waiting_on_ability = true
			targetting_ability.stopped_targetting.connect(func():
				input_waiting_on_ability = false
			,ConnectFlags.CONNECT_ONE_SHOT)
			targetting_ability.use(mouse_map_position)
			if !targetting_ability.is_valid_target(mouse_map_position):
				if selected_entity:
					selected_entity.clear_sprite_material()
					selected_entity = null
					UIManager.ui.clear_context()
				grid.tile_selected.emit(mouse_map_position)
				if is_instance_valid(hovered_entity) and hovered_entity.data.team == team_turn:
					hovered_entity.selected.emit()
					
		elif is_instance_valid(hovered_entity):
			print(">is_instance_valid(hovered_entity)")
			if hovered_entity.data.team == team_turn:
				hovered_entity.selected.emit()
			grid.tile_selected.emit(mouse_map_position)
		else:
			print(">else")
			grid.tile_selected.emit(mouse_map_position)
			UIManager.ui.clear_context()
			if selected_entity:
				selected_entity.clear_sprite_material()
				selected_entity = null
		
		print("*Tile Position: ",mouse_map_position)

func to_save_data():
	var entities = get_tree().get_nodes_in_group(C.GROUPS_ENTITIES)
	return {
		"team_turn":team_turn,
		"turn_order":turn_order,
		"entities":entities.map(func(e):return e.to_save_data())
	}
