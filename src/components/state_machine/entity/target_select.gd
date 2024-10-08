extends State
class_name EntityTargetSelectState

func _ready() -> void:
	state_id = C.STATE.ENTITY_TARGET_SELECT

func _transition():
	return C.STATE.ENTITY_IDLE
