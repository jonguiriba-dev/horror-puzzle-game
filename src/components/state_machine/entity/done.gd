extends State
class_name EntityDoneState

func _ready() -> void:
	super()
	state_id = C.STATE.ENTITY_DONE

func _enter_state(old_state, new_state):
	print("DONE")

	host.sprite.modulate = Color("626262")
			
