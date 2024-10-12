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
var is_enemy_obstacle = false
var target_count = 1
var knockback_distance = 0

signal target_select
signal stopped_targetting
signal applied(ability:Ability)


func _ready() -> void:
	target_select.connect(_on_target_select)
	stopped_targetting.connect(_on_ability_stopped_targetting)

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("click") and state == STATE.TARGET_SELECT):
		var target_map_position = WorldManager.grid.get_map_mouse_position()
		use(target_map_position)
		
func use(target_map_position:Vector2i):
	var target_entity = get_tree().get_first_node_in_group(C.GROUPS_HOVERED_ENTITIES)
	var reachable_tiles = get_reachable_tiles(ability_range)
	if reachable_tiles.has(target_map_position):
		await _play_animation()
		if is_instance_valid(target_entity):
			apply_effect(target_entity)
		
	stopped_targetting.emit()
	
func apply_effect(target):
	for action in actions:
		if action.type == AbilityAction.ABILITY_ACTION_TYPE.DAMAGE:
			target.hit.emit(damage)
		if action.type == AbilityAction.ABILITY_ACTION_TYPE.KNOCKBACK:
			target.knockback.emit(knockback_distance, WorldManager.grid.local_to_map(host.position))
			
	applied.emit(self)

func _play_animation():
	await Util.wait(0.3)
		
func set_state(_state:STATE):
	if _state == state:
		return
	if state == STATE.TARGET_SELECT:
		target_select.emit()
	
	
	state = _state
	
func _on_target_select() -> void:
	if host.action_counter == 0:
		return 
	set_state(STATE.TARGET_SELECT)
	host.add_to_group(C.GROUPS_TARGETTING_ENTITY)
	WorldManager.grid.is_ability_select = true
	highlight_range_tiles(ability_range)

func _on_ability_stopped_targetting() -> void:
	host.remove_from_group(C.GROUPS_TARGETTING_ENTITY)
	WorldManager.grid.clear_all_highlights(Grid.HIGHLIGHT_LAYERS.ABILITY)
	state = STATE.INACTIVE
	WorldManager.grid.is_ability_select = false
	
func highlight_range_tiles(_ability_range):
	WorldManager.grid.clear_all_highlights(Grid.HIGHLIGHT_LAYERS.ABILITY)
	var moveable_tile_positions = get_reachable_tiles(_ability_range)
	for pos in moveable_tile_positions:
		if highlight_color == Color.ORANGE:
			WorldManager.grid.set_highlight(pos,Grid.HIGHLIGHT_COLORS.ORANGE,Grid.HIGHLIGHT_LAYERS.ABILITY)
		else:
			WorldManager.grid.set_highlight(pos,Grid.HIGHLIGHT_COLORS.GREEN,Grid.HIGHLIGHT_LAYERS.ABILITY)
		
func get_reachable_tiles(_range:int):
	var possible_tiles = WorldManager.grid.get_possible_tiles(true,is_enemy_obstacle)
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
