extends State
class_name EntityTargetSelectState

#from selected
var to_selected = false
func _ready() -> void:
	super()
	state_id = C.STATE.ENTITY_TARGET_SELECT
	
func _enter_state(old_state, new_state):
	to_selected = false
	

func _transition():
	if to_selected:
		return C.STATE.ENTITY_SELECTED
