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
var range_pattern:Callable=TilePattern.generate_diamond_pattern
var aoe_pattern:Callable = TilePattern.point
var use_host_as_origin = false
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
signal used

func _ready() -> void:
	target_select.connect(_on_target_select)
	stopped_targetting.connect(_on_ability_stopped_targetting)
	
func use(target_map_position:Vector2i):
	if is_valid_target(target_map_position):
		await _play_animation(target_map_position)
		
		var direction = Util.get_direction(host.map_position,target_map_position)
		
		var origin = target_map_position
		
		if use_host_as_origin:
			origin = host.map_position + direction
			
		var affected_tiles = aoe_pattern.call(origin,ability_range,direction)
		for affected_tile in affected_tiles:
			var target_entity = _get_tile_target(affected_tile)
			if is_instance_valid(target_entity):
				apply_effect(target_entity)
		
		used.emit()
		
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
			
	applied.emit()

func _play_animation(target_map_position:Vector2i):
	await Util.wait(0.3)
		
func set_state(_state:STATE):
	if _state == state:
		return
	if state == STATE.TARGET_SELECT:
		target_select.emit()
	
	
	state = _state
func highlight_target_tiles():
	WorldManager.grid.clear_all_highlights(Grid.HIGHLIGHT_LAYERS.ABILITY)
	var target_tiles = get_target_tiles()
	
	for pos in target_tiles:
		if highlight_color == Color.ORANGE:
			WorldManager.grid.set_highlight(pos,Grid.HIGHLIGHT_COLORS.ORANGE,Grid.HIGHLIGHT_LAYERS.ABILITY)
		else:
			WorldManager.grid.set_highlight(pos,Grid.HIGHLIGHT_COLORS.GREEN,Grid.HIGHLIGHT_LAYERS.ABILITY)


func get_target_tiles(map_pos:Vector2i=host.map_position,_range:int=ability_range)->Array[Vector2i]:
	var possible_tiles = WorldManager.grid.get_possible_tiles(
		Grid.TILE_EXCLUDE_FLAGS.EXCLUDE_OBSTACLES + Grid.TILE_EXCLUDE_FLAGS.EXCLUDE_ALLIES
	)
	
	var tiles = range_pattern.call(map_pos,_range).filter(func(e):
		return possible_tiles.has(e)	
	)
	
	return tiles

func get_valid_targets(map_pos:Vector2i=Vector2i.ZERO)->Array[Entity]:
	if map_pos == Vector2i.ZERO:
		map_pos = host.map_position
	
	var targets:Array[Entity]=[]
	var reachable_tiles = get_target_tiles(map_pos,ability_range)
	if can_target_entities:
		for entity in host.get_enemies():
			if reachable_tiles.has(entity.map_position) :
				if entity != host:
					targets.push_front(entity)
	return targets
	

func get_threat_tiles(source_map_pos:Vector2i=Vector2i.ZERO,target_map_pos:Vector2i=Vector2i.ZERO)->Array:
	var direction = Util.get_direction(source_map_pos,target_map_pos)
	var threat_tiles = []
	
	var prev_tile = source_map_pos
	for i in range(ability_range):
		prev_tile += direction
		threat_tiles.push_front(prev_tile)
	
	return threat_tiles	

func is_valid_target(map_pos:Vector2i):
	var target_tiles = get_target_tiles(host.map_position,ability_range)
	if target_tiles.has(map_pos):
		return true
	return false

	
func _on_target_select() -> void:
	if host.action_counter == 0:
		return 
	set_state(STATE.TARGET_SELECT)
	add_to_group(C.GROUPS_TARGETTING_ABILITY)
	WorldManager.grid.is_ability_select = true
	highlight_target_tiles()

func _on_ability_stopped_targetting() -> void:
	remove_from_group(C.GROUPS_TARGETTING_ABILITY)
	WorldManager.grid.clear_all_highlights(Grid.HIGHLIGHT_LAYERS.ABILITY)
	state = STATE.INACTIVE
	WorldManager.grid.is_ability_select = false
	
