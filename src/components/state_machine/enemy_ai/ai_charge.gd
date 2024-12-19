extends AIAttackState
class_name AICharge

var heatmap = []

func _ready() -> void:
	super()
	state_id = C.STATE.AI_CHARGE
	
