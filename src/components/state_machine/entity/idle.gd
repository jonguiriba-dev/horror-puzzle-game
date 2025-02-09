extends State
class_name EntityIdleState


var to_done := false
var to_selected := false

func _ready() -> void:
	super()
	state_id = C.STATE.ENTITY_IDLE
	
func _enter_state(old_state, new_state):
	to_done = false
	to_selected = false
	host.sprite.modulate = Color("ffffff")
	
func _on_configured():
	host.selected.connect(_on_selected)
	
func _state_logic(delta:float):
	if host.data.move_counter == 0 and host.data.action_counter == 0:
		to_done = true
				
func _transition():
	if to_done:
		return  C.STATE.ENTITY_DONE
	if to_selected:
		return  C.STATE.ENTITY_SELECTED

func _on_selected():
	to_selected = true
