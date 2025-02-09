extends State
class_name EntityDoneState

var to_idle = false
func _ready() -> void:
	super()
	state_id = C.STATE.ENTITY_DONE
	to_idle = false
	
func _on_configured():
	host.turn_start.connect(_on_host_turn_start)

func _enter_state(old_state, new_state):
	host.sprite.modulate = Color("626262")
	to_idle = false
	host.turn_end.emit()
func _transition():
	if to_idle:
		return C.STATE.ENTITY_IDLE
	
func _on_host_turn_start():
	to_idle = true
	
