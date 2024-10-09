extends State
class_name EntitySelectedState

var to_target_select = false
func _ready() -> void:
	super()
	state_id = C.STATE.ENTITY_SELECTED
	to_target_select = false
	
func _on_configured():
	for ability in host.get_abilities():
		ability.target_select.connect(_on_ability_target_select)
		
func _enter_state(old_state, new_state):
	UIManager.ui.set_context(host)
	if host.move_counter > 0:
		host.select_ability("move")
	

func _on_ability_target_select():
	to_target_select = true

func _transition():
	if to_target_select:
		return  C.STATE.ENTITY_TARGET_SELECT
