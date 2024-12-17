extends State
class_name EntitySelectedState

#from idle
var to_target_select = false
var to_done = false
var to_idle = false


func _ready() -> void:
	super()
	state_id = C.STATE.ENTITY_SELECTED
	
func _on_configured():
	for ally in get_tree().get_nodes_in_group(C.GROUPS_PLAYER_ENTITIES):
		ally.selected.connect(_on_other_entity_selected)
	
	WorldManager.viewport_ready.connect(_on_scenetree_ready)
	host.selected.connect(_on_host_selected)
	
func _on_scenetree_ready():
	WorldManager.grid.tile_selected.connect(_on_tile_selected)


func _state_logic(delta:float):
	if host.move_counter == 0 and host.action_counter == 0:
		to_done = true

func _enter_state(old_state, new_state):
	to_done = false
	to_idle = false
	UIManager.ui.set_context(host)

	#UIManager.ui.set_context(host)
	if host.move_counter > 0 and host.action_counter > 0:
		Util.sysprint("EntitySelectedState._enter_state"," host.move_counter(%s) > 1, starting move"%[host.move_counter])
		host.get_ability("move").target_select.emit()
	
func _on_tile_selected(map_pos:Vector2i):
	if (get_tree().get_node_count_in_group(C.GROUPS_TARGETTING_ABILITY) == 0):
		#and ability.state != Ability.STATE.TARGET_SELECT):
		to_idle = true
		
func _on_other_entity_selected():
	to_idle = true
	
func _transition():
	if to_idle:
		return  C.STATE.ENTITY_IDLE
	if to_done:
		return  C.STATE.ENTITY_DONE


func _on_host_selected():
	if host.move_counter > 0 and host.action_counter > 0:
		host.get_ability("move").target_select.emit()
	
