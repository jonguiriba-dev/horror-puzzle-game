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
var can_target_entities:bool:
	get:
		for action in actions:
			match action.target_type:
				1:
					return true
				2:
					return true
		return false
var can_target_tiles:bool:
	get:
		for action in actions:
			match action.target_type:
				4:
					return true
		return false

signal target_select
signal stopped_targetting
signal applied(ability:Ability)


func _ready() -> void:
	target_select.connect(_on_target_select)
	stopped_targetting.connect(_on_ability_stopped_targetting)

func use(target_map_position:Vector2i):
	var reachable_tiles = get_reachable_tiles(host.map_position,ability_range)
	if reachable_tiles.has(target_map_position):
		await _play_animation()
		
		var target_entity = _get_tile_target(target_map_position)
		if is_instance_valid(target_entity):
			apply_effect(target_entity)
		
	stopped_targetting.emit()

func _get_tile_target(map_pos:Vector2i):
	var entities = get_tree().get_nodes_in_group(C.GROUPS_ENTITIES).filter(func(e):
		return e.map_position == map_pos
	)
	if entities.size() > 0:
		return entities[0]
	return null

func apply_effect(target):
	for action in actions:
		if action.action_type == AbilityAction.ACTION_TYPES.DAMAGE:
			target.hit.emit(damage)
		if action.action_type == AbilityAction.ACTION_TYPES.KNOCKBACK:
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
	add_to_group(C.GROUPS_TARGETTING_ABILITY)
	WorldManager.grid.is_ability_select = true
	highlight_range_tiles(ability_range)

func _on_ability_stopped_targetting() -> void:
	remove_from_group(C.GROUPS_TARGETTING_ABILITY)
	WorldManager.grid.clear_all_highlights(Grid.HIGHLIGHT_LAYERS.ABILITY)
	state = STATE.INACTIVE
	WorldManager.grid.is_ability_select = false
	
func highlight_range_tiles(_ability_range):
	WorldManager.grid.clear_all_highlights(Grid.HIGHLIGHT_LAYERS.ABILITY)
	
	var moveable_tile_positions = get_reachable_tiles(WorldManager.grid.local_to_map(host.position),_ability_range)
	
	for pos in moveable_tile_positions:
	
		if highlight_color == Color.ORANGE:
			WorldManager.grid.set_highlight(pos,Grid.HIGHLIGHT_COLORS.ORANGE,Grid.HIGHLIGHT_LAYERS.ABILITY)
		else:
			WorldManager.grid.set_highlight(pos,Grid.HIGHLIGHT_COLORS.GREEN,Grid.HIGHLIGHT_LAYERS.ABILITY)
		
func get_reachable_tiles(map_pos:Vector2i=host.map_position,_range:int=ability_range):
	var possible_tiles = WorldManager.grid.get_possible_tiles()
		
	var tiles = []
	for x in range(_range*-1, _range+1, 1):
		for y in range(_range*-1, _range+1, 1):
			var next_position = Vector2i(x+map_pos.x, y+map_pos.y)
			if(possible_tiles.has(next_position) and
			 WorldManager.grid.get_manhattan_distance(map_pos,next_position) <= _range ):
				if next_position != map_pos:
					var has_self = false
					
					if next_position != host.map_position:
						has_self = true
						tiles.append(next_position)
	return tiles

func get_valid_targets(map_pos:Vector2i)->Array[Entity]:
	var targets:Array[Entity]=[]
	var reachable_tiles = get_reachable_tiles(map_pos,ability_range)
	if can_target_entities:
		for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
			if reachable_tiles.has(entity.map_position) :
				targets.push_front(entity)
	return targets
	
