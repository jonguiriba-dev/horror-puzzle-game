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
	for ally in get_tree().get_nodes_in_group(C.GROUPS.PLAYER_ENTITIES):
		ally.selected.connect(_on_other_entity_selected)
	
	WorldManager.level.ready.connect(_on_scenetree_ready)
	host.selected.connect(_on_host_selected)
	
func _on_scenetree_ready():
	WorldManager.level.grid.tile_selected.connect(_on_tile_selected)


func _state_logic(delta:float):
	if host.data.move_counter == 0 and host.data.action_counter == 0:
		to_done = true

func _enter_state(old_state, new_state):
	to_done = false
	to_idle = false
	UIManager.level_ui.set_context(host)

	#UIManager.level_ui.set_context(host)
	print("HOST.DATA.MOVE ",host.data.move_counter)
	if host.data.move_counter > 0 and host.data.action_counter > 0:
		Util.sysprint(
			"EntitySelectedState._enter_state",
			" host.data.move_counter(%s) > 0 and host.data.action_counter(%s) > 0, starting move"%[host.data.move_counter,host.data.action_counter])
		var ability_move = host.get_ability("move")
		ability_move.target_select.emit()
		
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
	if host.data.move_counter > 0 and host.data.action_counter > 0:
		host.get_ability("move").target_select.emit()
	
