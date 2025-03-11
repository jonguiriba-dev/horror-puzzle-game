extends Object
class_name LevelStartSequenceHandler

var level:Level

func _init(level:Level):
	self.level = level
	
func _on_start_sequence_state_entered():
	Util.sysprint("Level","game start!")
	level.selected_entity = null
	
	#await register_entities()
	if !UIManager.level_ui:
		Util.sysprint("game_start","UIManager.level_ui not found")
		return
		
	level.clear_entity_moved_history()
	
	UIManager.level_ui.turn_start_overlay.hide()

	if Debug.play_game_start_sequence:
		await UIManager.play_game_start_sequence()
	
	#if Debug.play_game_start_dialogue:
		#for dialogue in level.dialogues:
			#if dialogue.trigger == C.DIALOGUE_TRIGGER.ON_START:
				#player_input_handler.current_dialogue = dialogue
				#player_input_handler.current_dialogue.input_waiting.connect(player_input_handler._on_dialogue_input_waiting)
				#await player_input_handler.current_dialogue.play(get_tree().get_nodes_in_group(C.GROUPS_ENTITIES))
	#player_input_handler.current_dialogue = null
	
