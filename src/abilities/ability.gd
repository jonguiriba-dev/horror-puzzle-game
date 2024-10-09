extends Node
class_name Ability

enum STATE{
	INACTIVE,
	TARGET_SELECT
}
@onready var host:Entity = get_parent()
var ability_name = "ability_name"
var texture = preload("res://assets/ui/ability_frame.png")
var ability_range = 0
var damage = 0
var state = STATE.INACTIVE
var actions:Array[AbilityAction]
var has_ui = true
var highlight_color = Color.ORANGE

signal target_select
signal stopped_targetting
signal applied(ability:Ability)


func _ready() -> void:
	target_select.connect(_on_target_select)
	stopped_targetting.connect(_on_ability_stopped_targetting)

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("click") and state == STATE.TARGET_SELECT):
		var can_target_tiles = false
		var can_target_entities = false
		
		for action in actions:
			if action.target_group == C.ABILITY_TARGET_GROUP.TILE:
				can_target_tiles = true
			if action.target_group == C.GROUPS_ENTITIES:
				can_target_entities = true
		
		var target
		if can_target_entities:
			target = get_tree().get_first_node_in_group(C.GROUPS_HOVERED_ENTITIES)
		elif can_target_tiles:
			target = {"position":WorldManager.grid.get_map_mouse_position()} 
		
		if target:
			print("Target found ", target)
			var host_map_position = WorldManager.grid.local_to_map(host.position)
			var target_map_position = target.position
			if target is Node2D:
				target_map_position = WorldManager.grid.local_to_map(target.position)
			var reachable_tiles = get_reachable_tiles(ability_range)
			if reachable_tiles.has(target_map_position):
				apply_effect(target)
				
		stopped_targetting.emit()
		
func apply_effect(target):
	print("apply_effect ",target)
	if !is_instance_valid(target):
		return 
		
	print("ability ",ability_name)
	for action in actions:
		print("action.target_group ", action.target_group)
		if target is Node and !target.is_in_group(action.target_group):
			print("target ", target)
			return
		if action.type == C.ABILITY_ACTION_TYPE.DAMAGE:
			print("hit ")
			target.hit.emit(damage)
		if action.type == C.ABILITY_ACTION_TYPE.MOVE:
			host.move_target_set.emit(target.position)
			
	applied.emit(self)
	print("apply_effect ", ability_name, " target ",target)

		
func set_state(_state:STATE):
	if _state == state:
		return
	if state == STATE.TARGET_SELECT:
		print("ability ",ability_name, " is targeting")
		target_select.emit()
	
	state = _state
	
func _on_target_select() -> void:
	print("_on_target_select")
	if host.action_counter == 0:
		return 
	set_state(STATE.TARGET_SELECT)
	host.add_to_group(C.GROUPS_TARGETTING_ENTITY)
	highlight_range_tiles(ability_range)

func _on_ability_stopped_targetting() -> void:
	print("_on_ability_stopped_targetting")
	host.remove_from_group(C.GROUPS_TARGETTING_ENTITY)
	WorldManager.grid.clear_all_highlights()
	state = STATE.INACTIVE
	
func highlight_range_tiles(_ability_range):
	WorldManager.grid.clear_all_highlights()
	var moveable_tile_positions = get_reachable_tiles(_ability_range)
	for pos in moveable_tile_positions:
		if highlight_color == Color.ORANGE:
			WorldManager.grid.set_highlight(pos,Grid.HIGHLIGHT_COLORS.ORANGE)
		else:
			WorldManager.grid.set_highlight(pos,Grid.HIGHLIGHT_COLORS.GREEN)
		
func get_reachable_tiles(_range:int):
	var possible_tiles = WorldManager.grid.get_possible_tiles(true,false)
	var map_position = WorldManager.grid.local_to_map(host.position)
	
	var tiles = []
	for x in range(_range*-1, _range+1, 1):
		for y in range(_range*-1, _range+1, 1):
			var next_position = Vector2i(x+map_position.x, y+map_position.y)
			if(possible_tiles.has(next_position) and
			 WorldManager.grid.get_manhattan_distance(map_position,next_position) <= _range ):
				if next_position != map_position:
					tiles.append(next_position)
	return tiles

func can_target_entities()->bool:
	for action in actions:
		if action.target_group == C.GROUPS_ENTITIES:
			return true
	return false
