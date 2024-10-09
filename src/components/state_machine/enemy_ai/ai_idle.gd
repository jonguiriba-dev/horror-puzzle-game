extends State
class_name AIIdleState

var to_attack := false

func _ready() -> void:
	super()
	state_id = C.STATE.AI_IDLE
	
func _on_configured():
	host.turn_start.connect(_on_turn_start)

func _enter_state(old_state, new_state):
	to_attack = false
	
func _transition():
	if to_attack:
		return  C.STATE.AI_ATTACK

func _on_turn_start(entity:Entity):
	to_attack = true
