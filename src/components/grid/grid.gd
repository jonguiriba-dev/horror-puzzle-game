extends Node2D
class_name Grid


enum HIGHLIGHT_LAYERS{
	ABILITY,
	ABILITY_AOE,
	THREAT,
	CURSOR,
	DEBUG
}


enum HIGHLIGHT_COLORS{
	GREEN = 0,
	ORANGE = 1,
	BLUE = 2,
	RED = 3,
	PURPLE = 4,
	NONE = 99,
}

enum TEAM_POSITION_LAYER_FILTERS{
	PLAYER,
	ENEMY,
	NEUTRAL
}

var CUSTOM_DATA_LAYER_TEAM_POSITION = "team_position"

@onready var tiles_layer :TileMapLayer= $TileMapLayer
@onready var ability_highlight_layer :TileMapLayer= $AbilityHighlightLayer
@onready var ability_aoe_highlight_layer :TileMapLayer= $AbilityAOEHighlightLayer
@onready var threat_highlight_layer :TileMapLayer= $ThreatHighlightLayer
@onready var debug_highlight_layer :TileMapLayer= $DebugHighlightLayer
@onready var cursor_layer :TileMapLayer= $CursorLayer
@onready var prop_layer :TileMapLayer= $PropLayer
@onready var team_position_layer :TileMapLayer= $TeamPositionLayer
@onready var astar_grid = AStarGrid2D.new()
@onready var grid_label = $GridLabel

var highlight_layer_map := {
}

#var enemy_threat_tiles:Array[Vector2i]= []
#var ally_threat_tiles:Array[Vector2i]= []
var highlight_tiles: Array[Vector2i]= []

var player_entity_tiles: Array[Vector2i]= []
var enemy_entity_tiles: Array[Vector2i]= []
var ally_entity_tiles: Array[Vector2i]= []
var neutral_entity_tiles: Array[Vector2i]= []
var prop_entity_tiles: Array[Vector2i]= []

signal tile_selected(map_pos: Vector2i)
@onready var level := get_parent()

func _ready() -> void:
	tile_selected.connect(_on_tile_selected)
	
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.cell_size = tiles_layer.tile_set.tile_size
	astar_grid.region = tiles_layer.get_used_rect()
	astar_grid.update()
	
	if grid_label:
		for cell_pos in tiles_layer.get_used_cells():
			var coord_label = Label.new()
			grid_label.add_child(coord_label)
			coord_label.position = map_to_local(cell_pos) + Vector2(-2,2)
			coord_label.text = "(%s,%s)" % [cell_pos.x, cell_pos.y]
			coord_label.set("theme_override_font_sizes/font_size",6)
		if !Debug.show_grid_coords_label:
			grid_label.hide()

	highlight_layer_map = {
		HIGHLIGHT_LAYERS.ABILITY: ability_highlight_layer,
		HIGHLIGHT_LAYERS.THREAT: threat_highlight_layer,
		HIGHLIGHT_LAYERS.DEBUG: debug_highlight_layer,
		HIGHLIGHT_LAYERS.CURSOR: cursor_layer,
		HIGHLIGHT_LAYERS.ABILITY_AOE: ability_aoe_highlight_layer,
	}
enum TILE_EXCLUDE_FLAGS{
	EXCLUDE_NONE = 0,
	EXCLUDE_OBSTACLES = 1,
	EXCLUDE_ENEMIES = 2,
	EXCLUDE_OBSTACLES_ENEMIES = 3,
	EXCLUDE_ALLIES = 4,
	EXCLUDE_OBSTACLES_ALLIES = 5,
	EXCLUDE_ALL_PROPS = 7,
	EXCLUDE_EMPTY = 8,
	EXCLUDE_OBSTACLES_EMPTY = 9,
	EXCLUDE_ENEMIES_OBSTACLES_EMPTY = 11,
}

var possible_tiles_cache:Dictionary = {}

func get_possible_tiles(team:C.TEAM,exclude_flags:int=7)->Array[Vector2i]:
	populate_entity_tiles()
	
	var entity_tiles: Array[Vector2i]= []
	entity_tiles.append_array(player_entity_tiles)
	entity_tiles.append_array(enemy_entity_tiles)
	entity_tiles.append_array(ally_entity_tiles)
	entity_tiles.append_array(neutral_entity_tiles)
	
	var enemy_tiles: Array[Vector2i]= []
	var ally_tiles: Array[Vector2i]= []

	enemy_tiles = enemy_entity_tiles
	ally_tiles = ally_entity_tiles
	ally_tiles.append_array(neutral_entity_tiles)
	ally_tiles.append_array(player_entity_tiles)
	
	if team == C.TEAM.ENEMY:
		enemy_tiles = ally_entity_tiles
		enemy_tiles.append_array(neutral_entity_tiles)
		enemy_tiles.append_array(player_entity_tiles)
		ally_tiles = enemy_entity_tiles
	
	var tiles = tiles_layer.get_used_cells()
	var props = prop_layer.get_used_cells()
	
	astar_grid.fill_solid_region(astar_grid.region,false)
	if (exclude_flags & TILE_EXCLUDE_FLAGS.EXCLUDE_OBSTACLES) != 0:
		for prop_pos in props:
			tiles.erase(prop_pos)
			astar_grid.set_point_solid(prop_pos)
		for prop_pos in prop_entity_tiles:
			tiles.erase(prop_pos)
			astar_grid.set_point_solid(prop_pos)
	
	if (exclude_flags & TILE_EXCLUDE_FLAGS.EXCLUDE_ENEMIES) != 0:
		for enemy_pos in enemy_tiles:
			tiles.erase(enemy_pos)
			astar_grid.set_point_solid(enemy_pos)
			
	if (exclude_flags & TILE_EXCLUDE_FLAGS.EXCLUDE_ALLIES) != 0:
		for ally_pos in ally_tiles:
			tiles.erase(ally_pos)
			astar_grid.set_point_solid(ally_pos)
			
	if (exclude_flags & TILE_EXCLUDE_FLAGS.EXCLUDE_EMPTY) != 0:
		for tile in tiles.duplicate():
			if (
				!enemy_tiles.has(tile) and
				!ally_tiles.has(tile) and
				!props.has(tile) 
			):
				tiles.erase(tile)
				astar_grid.set_point_solid(tile)
	
	return tiles

func get_navigatable_tiles(
	start_position:Vector2i,
	max_steps:int,
	team:C.TEAM,
	exclude_flags:int=TILE_EXCLUDE_FLAGS.EXCLUDE_ALL_PROPS
)->Array[Vector2i]:
	var navigatable_tiles:Array[Vector2i]= []
	
	var possible_tiles = WorldManager.level.grid.get_possible_tiles(
		team,
		exclude_flags
	)
	var queued_tiles = [start_position]
		
	var step = 0
	while !queued_tiles.is_empty():
		var pending_tiles = queued_tiles.duplicate()
		queued_tiles = []
		for direction in [Vector2i(-1,0),Vector2i(1,0),Vector2i(0,-1),Vector2i(0,1)]:
			for pending_tile in pending_tiles:
				var next_tile = pending_tile + direction
				if possible_tiles.has(next_tile) and !navigatable_tiles.has(next_tile):
					if (
						start_position != next_tile and 
						!WorldManager.level.grid.ally_entity_tiles.has(next_tile)
					):
						navigatable_tiles.push_front(next_tile)
					queued_tiles.push_front(next_tile)
		step += 1
		if step == max_steps:
			break
	return navigatable_tiles



func get_all_tiles()->Array[Vector2i]:
	return tiles_layer.get_used_cells()

func set_highlight(map_position:Vector2i, color:HIGHLIGHT_COLORS,layer:HIGHLIGHT_LAYERS):
	if color == HIGHLIGHT_COLORS.NONE:
		highlight_tiles.erase(map_position)
		highlight_layer_map[layer].erase_cell(map_position)
	else:
		highlight_tiles.push_front(map_position)
		highlight_layer_map[layer].set_cell(map_position,0,Vector2i(color,0))

func set_highlight_area(
	map_area:Array[Vector2i], 
	color:HIGHLIGHT_COLORS=HIGHLIGHT_COLORS.GREEN,
	layer:HIGHLIGHT_LAYERS=HIGHLIGHT_LAYERS.DEBUG
):
	for map_position in map_area:
			
		if color == HIGHLIGHT_COLORS.NONE:
			highlight_tiles.erase(map_position)
			highlight_layer_map[layer].erase_cell(map_position)
		else:
			highlight_tiles.push_front(map_position)
			highlight_layer_map[layer].set_cell(map_position,0,Vector2i(color,0))
		
func clear_all_highlights(layer:HIGHLIGHT_LAYERS):
	highlight_layer_map[layer].clear()


func get_grid_local_mouse_position()->Vector2:
	return prop_layer.get_local_mouse_position()
	
func get_map_mouse_position()->Vector2i:
	return prop_layer.local_to_map(prop_layer.get_local_mouse_position())
	
func is_within_range(a:Vector2,b:Vector2,_range:int) -> bool:
	return Util.get_manhattan_distance(a,b) <= _range

func local_to_map(local_pos:Vector2)->Vector2i:
	return prop_layer.local_to_map(local_pos)

func map_to_local(map_pos:Vector2i)->Vector2:
	return prop_layer.map_to_local(map_pos)
	
func get_nearest_path(
	team:C.TEAM, 
	source:Vector2i,
	target:Vector2i,
	exclude_flags := TILE_EXCLUDE_FLAGS.EXCLUDE_OBSTACLES_ALLIES
)->Array[Vector2i]:
	get_possible_tiles(
		team, 
		exclude_flags
	)
	var path = astar_grid.get_id_path(source, target)
	if path.size() > 0:
		path.remove_at(0)
	return path
	
func is_within_bounds(map_pos:Vector2i):
	var rect = tiles_layer.get_used_rect()
	return rect.has_point(map_pos)

func _on_tile_selected(map_pos:Vector2i):
	set_map_cursor(map_pos)
	clear_all_highlights(Grid.HIGHLIGHT_LAYERS.ABILITY_AOE)
func set_map_cursor(map_pos:Vector2i):
	cursor_layer.clear()
	cursor_layer.set_cell(map_pos,1,Vector2i(0,0))
	
func debug_tile_text(map_pos:Vector2i,text:String):
	var label = Label.new()
	label.text = text
	label.set("theme_override_font_sizes/font_size", 10)
	label.set("theme_override_colors/font_color", Color.YELLOW)
	label.set("theme_override_colors/font_shadow", Color.BLACK)
	debug_highlight_layer.add_child(label)
	label.position = debug_highlight_layer.map_to_local(map_pos) 
	label.position.y -= 40
	label.position.x -= 10
	label.z_index = 99


func populate_entity_tiles():
	player_entity_tiles = []
	enemy_entity_tiles = []
	ally_entity_tiles = []
	neutral_entity_tiles = []
	prop_entity_tiles = []
	
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
		if entity.data.team == C.TEAM.PLAYER:
			player_entity_tiles.push_front(entity.map_position)
		if entity.data.team == C.TEAM.ENEMY:
			enemy_entity_tiles.push_front(entity.map_position)
		if entity.data.team == C.TEAM.ALLY:
			ally_entity_tiles.push_front(entity.map_position)
		if entity.data.team == C.TEAM.CITIZEN:
			neutral_entity_tiles.push_front(entity.map_position)
		if entity.data.team == C.TEAM.PROP:
			prop_entity_tiles.push_front(entity.map_position)
		
func highlight_threat_tiles(enemy_threat_tiles,ally_threat_tiles):
	clear_all_highlights(HIGHLIGHT_LAYERS.THREAT)
	Util.sysprint("grid.highlight_threat_tiles()|enemy_threat_tiles",str(enemy_threat_tiles))
	Util.sysprint("grid.highlight_threat_tiles()|ally_threat_tiles",str(ally_threat_tiles))
	for tile_position in enemy_threat_tiles:
		var color = HIGHLIGHT_COLORS.RED
		if ally_threat_tiles.has(tile_position):
			color = HIGHLIGHT_COLORS.PURPLE
		
		set_highlight(tile_position,color,HIGHLIGHT_LAYERS.THREAT)
		
	for tile_position in ally_threat_tiles:
		var color = HIGHLIGHT_COLORS.BLUE
		if enemy_threat_tiles.has(tile_position):
			color = HIGHLIGHT_COLORS.PURPLE
		set_highlight(tile_position,color,HIGHLIGHT_LAYERS.THREAT)

func get_entity_on_tile(map_pos:Vector2i):
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
		if entity.map_position == map_pos:
			return entity
	return null

func is_empty_tile(map_pos:Vector2i):
	populate_entity_tiles()
	
	var tiles = tiles_layer.get_used_cells()
	var props = prop_layer.get_used_cells()
	
	if (
		!enemy_entity_tiles.has(map_pos) and
		!ally_entity_tiles.has(map_pos) and
		!props.has(map_pos) and 
		tiles.has(map_pos)
	):
		return true
	return false
 
func get_team_position_tiles(filter:TEAM_POSITION_LAYER_FILTERS):
	var tiles = []
	for cell in team_position_layer.get_used_cells():
		var cell_data := team_position_layer.get_cell_tile_data(cell)
		var team_position = cell_data.get_custom_data(CUSTOM_DATA_LAYER_TEAM_POSITION)
		
		match filter:
			TEAM_POSITION_LAYER_FILTERS.PLAYER:
				if team_position == 'player':
					tiles.push_front(cell) 
			TEAM_POSITION_LAYER_FILTERS.ENEMY:
				if team_position == 'enemy':
					tiles.push_front(cell) 
			TEAM_POSITION_LAYER_FILTERS.NEUTRAL:
				if team_position == 'citizen':
					tiles.push_front(cell) 
	return tiles

func add_child_entity(entity:Entity):
	Util.sysprint("Grid","adding child %s"%[entity.data.entity_name])
	prop_layer.add_child(entity)
	WorldManager.level.register_entity(entity)

func remove_child_entity(entity:Entity):
	Util.sysprint("Grid","removing child %s"%[entity.data.entity_name])
	prop_layer.remove_child(entity)
	
