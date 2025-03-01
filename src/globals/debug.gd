extends Node

var is_enabled = true
var show_enemy_ai_tile_values = false
var show_grid_coords_label = false
var show_move_path_highlight = false
var show_turn_card = false
var highlight_enemy_target = false
var play_game_start_sequence = false
var play_game_start_dialogue = false
var highlight_entity_in_action = true

func _physics_process(delta: float) -> void:
	if !WorldManager.level or !WorldManager.level.grid:
		return
	if is_enabled:
		var text = ""
		text += "\nmouse_pos: %s"%WorldManager.level.grid.get_grid_local_mouse_position()
		text += "\nmouse_map_pos: %s"%WorldManager.level.grid.get_map_mouse_position()
		text += "\ninput_enabled: %s"%WorldManager.level.input_enabled
		text += "\nanimation_counter: %s"%AnimationManager.animation_counter
		text += "\nturn: %s"%C.TEAM.keys()[WorldManager.level.team_turn]
		text += "\nstrategy: %s"%C.STRATEGIES.keys()[WorldManager.level.strategy]
		text += "\nstarting_position: %s"%C.DIRECTION.keys()[WorldManager.level.starting_position]
		text += "\nentity turn queue: %s"%", ".join(WorldManager.level.ai_turn_queue.map(func(e): if is_instance_valid(e): return e.data.entity_name))
		if is_instance_valid(WorldManager.level.current_ai_entity_in_action):
			text += "\nentity in action: %s"%WorldManager.level.current_ai_entity_in_action.data.entity_name
		var node = get_tree().get_first_node_in_group(C.GROUPS_HOVERED_ENTITIES)
		if !node:
			UIManager.info(text)
			return 
		
		
		var entity = node as Entity
		text += "\nhealth: %s"%entity.data.health
		text += "\nstatus_effects: %s"%str(entity.status_effects)
		if entity.has_node("PlayerEntityStateMachine"):
			var state_machine = entity.get_node("PlayerEntityStateMachine")
			var state = state_machine.get_state() as State
			text += "\n %s"%[C.STATE.keys()[state.state_id]]
			text += "\nmove_counter: %s"%entity.data.move_counter
			text += "\naction_counter: %s"%entity.data.action_counter
		elif entity.has_node("EnemyAiStateMachine"):
			var state_machine = entity.get_node("EnemyAiStateMachine")
			var state = state_machine.get_state() as State
			text += "\n %s"%[C.STATE.keys()[state.state_id]]
			text += "\nmove_counter: %s"%entity.data.move_counter
			text += "\naction_counter: %s"%entity.data.action_counter
			if entity.has_meta("distance_to_bounds"):
				text += "\ndistance_to_bounds: %s"%entity.get_meta("distance_to_bounds")
			if entity.has_meta("distance_to_host"):
				text += "\ndistance_to_host: %s"%entity.get_meta("distance_to_host")
		UIManager.info(text)

func _on_test_button_pressed():
	var entity = get_tree().get_first_node_in_group(C.GROUPS_ENEMIES)
	entity.get_ability("strike").get_reachable_tiles()
