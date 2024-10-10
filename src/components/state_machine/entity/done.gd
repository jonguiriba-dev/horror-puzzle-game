extends State
class_name EntityDoneState

func _ready() -> void:
	super()
	state_id = C.STATE.ENTITY_DONE

func _on_configured():
	host.

func _enter_state(old_state, new_state):
	host.sprite.modulate = Color("626262")
			
func _transition():
	
