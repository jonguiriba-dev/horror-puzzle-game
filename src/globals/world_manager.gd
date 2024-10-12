extends Node

var grid: Grid
var team_turn:C.TEAM
var turn_order:=[C.TEAM.PLAYER,C.TEAM.ENEMY]
var enemy_turn_queue = []

signal turn_changed
signal turn_start(team: C.TEAM)
signal turn_end(team: C.TEAM)
signal viewport_ready


func _ready() -> void:
	get_viewport().ready.connect(_on_scenetree_ready)
	UIManager.initialized.connect(_on_ui_manager_initalized)
	team_turn = turn_order[0]
	turn_start.connect(_on_turn_start)
	

func _on_scenetree_ready():
	_start_player_turn()
	viewport_ready.emit()
	
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
	if team_turn == C.TEAM.PLAYER:
		_start_player_turn()
		
func _start_player_turn():
	print("world manager start turn")
	for player_entities in get_tree().get_nodes_in_group(C.GROUPS_PLAYER_ENTITIES):
		player_entities.turn_start.emit()

func _on_turn_start(turn:C.TEAM):
	if turn == C.TEAM.ENEMY:
		_on_enemy_turn_start()
		
func _on_enemy_turn_start():
	grid.threat_tiles = []
	enemy_turn_queue = get_tree().get_nodes_in_group(C.GROUPS_ENEMIES)
	
	if enemy_turn_queue.size() > 0:
		var enemy = enemy_turn_queue.pop_front()
		enemy.turn_start.emit()
			
func _on_enemy_unit_turn_end():
	if enemy_turn_queue.size() == 0 and team_turn == C.TEAM.ENEMY:
		end_turn()
		
	var enemy = enemy_turn_queue.pop_front()
	if enemy:
		enemy.turn_start.emit()
		
func _on_enemy_unit_turn_start(entity:Entity):
	entity.show_detail("rescue")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		pass

func register_entity(entity:Entity):
	if entity.team == C.TEAM.ENEMY:
		entity.turn_end.connect(_on_enemy_unit_turn_end)
