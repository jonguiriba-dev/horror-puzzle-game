extends State
class_name EntityMoveSelectState

var has_selected = false

func _ready() -> void:
	state_id = C.STATE.ENTITY_MOVE_SELECT

func _enter_state(old_state, new_state):
	has_selected = false
	host.show_move_range()

func _on_unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") :
		var mouse_map_pos = WorldManager.grid.get_map_mouse_position()
		var is_within_range = host.get_moveable_tiles(host.move_range).has(WorldManager.grid.get_map_mouse_position())
		
		if(is_within_range):
			host.move_to_selected_tile(mouse_map_pos)
			
		has_selected = true
		remove_from_group(C.GROUPS.TARGETTING_ENTITY)
		WorldManager.grid.clear_all_highlights()
		
func _transition():
	if has_selected:
		return  C.STATE.ENTITY_IDLE
		
