extends Control
class_name Level

@export var dialogues:Array[Dialogue]=[]
@export var level_preset:LevelPreset

@onready var grid: Grid = $Grid
@onready var state_chart:LevelStateChart = $StateChart

var entity_moved_history:=[]
var entity_register_queue := []
var selected_entity:Entity
var strategy := C.STRATEGIES.NEAREST
var strategy_changed := false
var starting_position := C.DIRECTION.NORTH

var level_gold = 10
var level_exp = 0
var loaded_data

signal loaded

var player_input_handler :LevelPlayerInputHandler
var load_handler :LevelLoader
var end_sequence_handler :LevelEndSequenceHandler
var start_sequence_handler :LevelStartSequenceHandler
var turn_handler :LevelTurnHandler

func _enter_tree() -> void:
	WorldManager.register_level(self)
	
func _ready() -> void:
	player_input_handler = LevelPlayerInputHandler.new(self)
	load_handler = LevelLoader.new(self)
	end_sequence_handler = LevelEndSequenceHandler.new(self)
	start_sequence_handler = LevelStartSequenceHandler.new(self)
	turn_handler = LevelTurnHandler.new(self)
	
	UIManager.set_ui(UIManager.UI_TYPE.LEVEL)
	UIManager.level_ui.undo_move_pressed.connect(_on_undo_move_pressed)
	UIManager.level_ui.end_turn_pressed.connect(turn_handler._on_end_turn_pressed)
	UIManager.level_ui.turn_order_pressed.connect(turn_handler._on_turn_order_pressed)
	UIManager.level_ui.strategy_changed.connect(func ():
		strategy_changed = true
	)
	WorldManager.set_meta("player_targetting_ability",null)
	
	state_chart.states.load.state_entered.connect(load_handler._on_load_state_entered)
	state_chart.states.start_sequence.state_entered.connect(start_sequence_handler._on_start_sequence_state_entered)
	state_chart.states.player_turn.state_entered.connect(turn_handler._on_player_turn_state_entered)
	state_chart.states.player_turn.state_exited.connect(turn_handler._on_turn_end)
	
	state_chart.states.player_turn.state_input.connect(
		player_input_handler._on_player_turn_state_input
	)
	state_chart.states.ai_turn.state_entered.connect(turn_handler._on_ai_turn_state_entered)
	state_chart.states.ai_turn.state_exited.connect(turn_handler._on_turn_end)
	state_chart.states.end_sequence.state_entered.connect(end_sequence_handler._on_end_sequence_state_entered)
	state_chart.states.unload.state_entered.connect(load_handler._on_unload_state_entered)
	
func check_player_victory():
	if get_tree().get_nodes_in_group(C.GROUPS_ENEMIES).size() == 0:
		state_chart.send_event("end_sequence")


func show_next_level_options():
	var level_count = 3
	for i in range(level_count):
		pass

func clear_entity_moved_history():
	entity_moved_history.clear()
	if UIManager.level_ui:
		UIManager.level_ui.disable_undo_move_button()
		


var order_labels = []
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

func register_entity(entity:Entity):
	if !grid:
		entity_register_queue.push_front(entity)
		return
		
	entity.death.connect(func():
		clear_entity(entity)
	)
		
	if entity.data.team == C.TEAM.ENEMY or entity.data.team == C.TEAM.ALLY:
		entity.turn_end.connect(turn_handler._on_ai_unit_turn_end)
		
	if entity.data.team == C.TEAM.PLAYER or entity.data.team == C.TEAM.ALLY or entity.data.team == C.TEAM.CITIZEN:
		entity.set_orientation(level_preset.orientation == C.ORIENTATION.VERTICAL) 

	if entity.data.team == C.TEAM.ENEMY:
		if level_preset.orientation == C.ORIENTATION.VERTICAL:
			entity.set_orientation(level_preset.orientation == C.ORIENTATION.VERTICAL)
			#entity.set_orientation(orientation == C.ORIENTATION.HORIZONTAL)
		else:
			entity.set_orientation(level_preset.orientation == C.ORIENTATION.HORIZONTAL)
			#entity.set_orientation(orientation == C.ORIENTATION.VERTICAL)
	
	entity.threat_updated.connect(_on_entity_threat_updated)
	entity.turn_end.connect(_on_unit_turn_end)
	entity.sprite.speed_scale = SystemManager.idle_animation_speed
	entity.position = grid.map_to_local(entity.map_position)
	entity.registered.emit()

func clear_entity(entity:Entity):
	if entity.animation_counter == 0:
		grid.remove_child_entity(entity)
	else:
		await AnimationManager.animation_cleared
		grid.remove_child_entity(entity)


		

func _on_unit_turn_end():
	SaveManager.save_data("level",to_save_data())
	SaveManager.save_game()


func _on_enemy_unit_turn_start(entity:Entity):
	entity.show_detail("rescue")

func _on_undo_move_pressed():
	if entity_moved_history.size() > 0:
		var history = entity_moved_history.pop_front() as Dictionary
		history["entity"].undo_move(history["prev_map_position"])
		
		if entity_moved_history.size() == 0:
			clear_entity_moved_history()

func _on_entity_threat_updated():
	var enemy_threats = get_team_group_threat_tiles(C.GROUPS_ENEMIES)
	enemy_threats.append_array(get_team_group_threat_tiles(C.GROUPS.PROPS))
	grid.highlight_threat_tiles(
		enemy_threats,
		get_team_group_threat_tiles(C.GROUPS_ALLIES)
	)

func _on_running_state_entered():
	var targetting_ability = Util.get_meta_from_node(WorldManager,"player_targetting_ability")
	

func to_save_data():
	var entities = get_tree().get_nodes_in_group(C.GROUPS_ENTITIES)
	return {
		"team_turn":turn_handler.team_turn,
		"turn_order":turn_handler.turn_order,
		"entities":entities.map(func(e):return e.to_save_data())
	}
																		
