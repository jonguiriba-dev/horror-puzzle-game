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
	if host.team == C.TEAM.ALLY and to_attack:
		if (
			WorldManager.level.strategy == C.STRATEGIES.FORWARD
		):
			return C.STATE.AI_FORWARD
		elif (
			WorldManager.level.strategy == C.STRATEGIES.RETREAT
		):
			return C.STATE.AI_RETREAT
		elif (
			WorldManager.level.strategy == C.STRATEGIES.SPREAD
		):
			return C.STATE.AI_SPREAD
		elif (
			WorldManager.level.strategy == C.STRATEGIES.TOGETHER
		):
			return C.STATE.AI_TOGETHER
		elif (
			WorldManager.level.strategy == C.STRATEGIES.NEAREST
		):
			return C.STATE.AI_ATTACK
	elif to_attack:
		return  C.STATE.AI_ATTACK

func _on_turn_start():
	to_attack = true
