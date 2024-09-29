extends Node

var active_tilemap: CustomTileMapLayer
var team_turn:C.TEAM

var turn_order:=[C.TEAM.PLAYER,C.TEAM.ENEMY]

signal turn_changed
signal turn_start(turn: C.TEAM)
signal turn_end(turn: C.TEAM)

func _ready() -> void:
	UIManager.initialized.connect(_on_ui_manager_initalized)
	team_turn = turn_order[0]
	
func _on_ui_manager_initalized():
	UIManager.ui.end_turn_pressed.connect(_on_end_turn_pressed)

func _on_end_turn_pressed():
	turn_changed.emit
	turn_end.emit(turn_order[0])
	turn_order.push_front(turn_order.pop_back())
	turn_start.emit(turn_order[0])
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var need_highlight = false
		for unit in get_tree().get_nodes_in_group(C.GROUPS.UNITS):
			if unit.state == Unit.STATE.MOVE_SELECTION:
				need_highlight = true
					
		if !need_highlight:
			WorldManager.active_tilemap.clear_all_highlights()
				
