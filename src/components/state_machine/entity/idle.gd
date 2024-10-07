extends State
class_name EntityIdleState


var to_done := false
var to_move_select := false

func _ready() -> void:
	state_id = C.STATE.ENTITY_IDLE

func _enter_state(old_state, new_state):
	to_move_select = false	
	to_done = false
	host.sprite.modulate = Color("ffffff")
	
func _on_unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and host.move_counter > 0:
		if host.is_in_group(C.HOVERED_ENTITIES):
			to_move_select = true
	
	if host.move_counter == 0 and host.action_counter == 0:
		to_done = true
	
				
func _transition():
	if to_done:
		return  C.STATE.ENTITY_DONE
	if to_move_select:
		return  C.STATE.ENTITY_MOVE_SELECT
			
