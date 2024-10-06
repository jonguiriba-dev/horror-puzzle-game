extends Node

var grid: Grid
var team_turn:C.TEAM

var turn_order:=[C.TEAM.PLAYER,C.TEAM.ENEMY]

var enemy_turn_queue = []

signal turn_changed
signal turn_start(team: C.TEAM)
signal turn_end(team: C.TEAM)

func _ready() -> void:
	UIManager.initialized.connect(_on_ui_manager_initalized)
	team_turn = turn_order[0]
	turn_start.connect(_on_turn_start)
		
func _on_ui_manager_initalized():
	UIManager.ui.end_turn_pressed.connect(_on_end_turn_pressed)

func _on_end_turn_pressed():
	end_turn()

func end_turn():
	turn_changed.emit()
	turn_end.emit(team_turn)
	turn_order.push_front(turn_order.pop_back())
	team_turn = turn_order[0]
	turn_start.emit(team_turn)

func _on_turn_start(team:C.TEAM):
	if team == C.TEAM.ENEMY:
		grid.threat_tiles = []
		enemy_turn_queue = get_tree().get_nodes_in_group(C.GROUPS.ENEMIES)
		
		var enemy
		while enemy == null:
			if enemy_turn_queue.size() == 0:
				break
			enemy = enemy_turn_queue.pop_front()
		
		if enemy:
			enemy.turn_start.emit(enemy)
		
func _on_enemy_unit_turn_end(entity:Entity):
	entity.hide_all_details()
	if enemy_turn_queue.size() == 0 and team_turn == C.TEAM.ENEMY:
		end_turn()
		
	var enemy = enemy_turn_queue.pop_front()
	if enemy:
		enemy.turn_start.emit(enemy)
		
func _on_enemy_unit_turn_start(entity:Entity):
	entity.show_detail("rescue")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var need_highlight = false
		for unit in get_tree().get_nodes_in_group(C.GROUPS.UNITS):
			if unit.state == Unit.STATE.MOVE_SELECTION:
				need_highlight = true
					
		if !need_highlight:
			WorldManager.grid.clear_all_highlights()
				
