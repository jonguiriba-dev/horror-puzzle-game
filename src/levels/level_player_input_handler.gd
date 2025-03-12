extends Object
class_name LevelPlayerInputHandler

enum STATES {
	WAITING_ON_ABILITY,
}

var input_enabled := true
var state := STATES.WAITING_ON_ABILITY

var level:Level

var waiting_on_ability
var input_waiting_on_dialogue
var selected_entity
var current_dialogue:Dialogue


func _init(level:Level):
	self.level = level
	current_dialogue = null
func _on_player_turn_state_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_handle_mouse_motion()
		
	if event.is_action_pressed("click") :
		Util.sysprint("Level._unhandled_input()","click")
		var mouse_map_position = level.grid.local_to_map(level.grid.get_local_mouse_position())
		
		var hovered_entity = WorldManager.get_tree().get_first_node_in_group(C.GROUPS_HOVERED_ENTITIES)
		if hovered_entity:
			Util.sysprint("WorldManager._unhandled_input()","entity hovered: %s"%[hovered_entity.data.entity_name])
		
		var targetting_ability = Util.get_meta_from_node(WorldManager,"player_targetting_ability")
		if targetting_ability:
			Util.sysprint("WorldManager._unhandled_input()","targetting ability: %s"%[targetting_ability.data.ability_name])
		
		if waiting_on_ability:
			print(">waiting_on_ability return")
			return
		if !input_enabled:
			return
			
		if selected_entity and !targetting_ability:
			print(">selected_entity and !targetting_abilit")
			selected_entity.clear_sprite_material()
			selected_entity = null
		
		if input_waiting_on_dialogue:
			current_dialogue.input_recieved.emit()
			input_waiting_on_dialogue = false
		
		if UIManager.ability_hovered:
			UIManager.ability_hovered.target_select.emit()	
			
		if targetting_ability and !waiting_on_ability:		
			UIManager.level_ui.clear_context()
			if selected_entity and targetting_ability.data.ability_name.to_lower() != "move":
				selected_entity.clear_sprite_material()
				selected_entity = null
			waiting_on_ability = true
			targetting_ability.stopped_targetting.connect(func():
				waiting_on_ability = false
			,ConnectFlags.CONNECT_ONE_SHOT)
			
			print("ABILITY USED ON ", mouse_map_position)
			targetting_ability.use(mouse_map_position)
			
			if !targetting_ability.is_valid_target(mouse_map_position):
				if selected_entity:
					selected_entity.clear_sprite_material()
					selected_entity = null
				level.grid.tile_selected.emit(mouse_map_position)
				if is_instance_valid(hovered_entity) and hovered_entity.data.team == level.turn_handler.team_turn:
					hovered_entity.selected.emit()
					
		elif is_instance_valid(hovered_entity):
			print(">is_instance_valid(hovered_entity)")
			if hovered_entity.data.team == level.turn_handler.team_turn:
				hovered_entity.selected.emit()
			level.grid.tile_selected.emit(mouse_map_position)
		else:
			print(">else")
			level.grid.tile_selected.emit(mouse_map_position)
			UIManager.level_ui.clear_context()
			if selected_entity:
				selected_entity.clear_sprite_material()
				selected_entity = null
		
		print("*Tile Position: ",mouse_map_position)

func _handle_mouse_motion():
	var targetting_ability = Util.get_meta_from_node(WorldManager,"player_targetting_ability")
	if targetting_ability:
		var mouse_pos = level.grid.get_map_mouse_position()
		
		level.grid.clear_all_highlights(
			Grid.HIGHLIGHT_LAYERS.ABILITY_AOE
		)
		
		if targetting_ability.get_target_tiles(targetting_ability.host.map_position).has(mouse_pos):
			
			targetting_ability = targetting_ability as AbilityV2
			var threat_tiles = targetting_ability.get_threat_tiles(
				targetting_ability.host.map_position,
				level.grid.get_map_mouse_position()
			)
			level.grid.set_highlight_area(
				threat_tiles,
				Grid.HIGHLIGHT_COLORS.BLUE,
				Grid.HIGHLIGHT_LAYERS.ABILITY_AOE)

func _on_dialogue_input_waiting():
	input_waiting_on_dialogue = true
