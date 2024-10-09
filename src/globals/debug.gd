extends Node

var is_enabled = true
var show_enemy_ai_tile_values = false
var show_move_path_highlight = false

func _physics_process(delta: float) -> void:
	if is_enabled:
		var text = ""
		var node = get_tree().get_first_node_in_group(C.GROUPS_HOVERED_ENTITIES)
		if !node:
			UIManager.info(text)
			return 
		var entity = node as Entity
		if entity.has_node("PlayerEntityStateMachine"):
			var state_machine = entity.get_node("PlayerEntityStateMachine")
			var state = state_machine.get_state() as State
			text += "\n %s"%[C.STATE.keys()[state.state_id]]
			text += "\nmove_counter: %s"%entity.move_counter
			text += "\naction_counter: %s"%entity.action_counter
		elif entity.has_node("EnemyAiStateMachine"):
			var state_machine = entity.get_node("EnemyAiStateMachine")
			var state = state_machine.get_state() as State
			text += "\n %s"%[C.STATE.keys()[state.state_id]]
			text += "\nmove_counter: %s"%entity.move_counter
			text += "\naction_counter: %s"%entity.action_counter
		UIManager.info(text)
