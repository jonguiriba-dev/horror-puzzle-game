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
	#for ability in host.get_abilities():
		#ability.target_select.connect(_on_ability_target_select)
		#ability.stopped_targetting.connect(_on_ability_stopped_targetting)
	
	for ally in get_tree().get_nodes_in_group(C.GROUPS_PLAYER_ENTITIES):
		ally.selected.connect(_on_other_entity_selected)
	
	WorldManager.viewport_ready.connect(_on_scenetree_ready)

func _on_scenetree_ready():
	WorldManager.grid.tile_selected.connect(_on_tile_selected)

func _on_unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("click"):
		#if !host.is_in_group(C.GROUPS_HOVERED_ENTITIES): 
			#to_idle = true
	pass		

func _state_logic(delta:float):
	if host.move_counter == 0 and host.action_counter == 0:
		to_done = true

func _enter_state(old_state, new_state):
	host.selected.emit()
	to_done = false
	to_idle = false
	UIManager.ui.set_context(host)
	UIManager.ui.undo_move_pressed.connect(_on_undo_move_pressed)
	if host.move_counter > 0 and host.action_counter > 0:
		host.get_ability("move").target_select.emit()	

func _exit_state(old_state, new_state):
	UIManager.ui.undo_move_pressed.disconnect(_on_undo_move_pressed)
	
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

func _on_undo_move_pressed():
	to_idle = true
	host.undo_move()
