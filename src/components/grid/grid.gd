extends Node2D
class_name Grid


enum HIGHLIGHT_LAYERS{
	ABILITY,
	THREAT,
	DEBUG
}

enum HIGHLIGHT_COLORS{
	GREEN = 0,
	ORANGE = 1,
	BLUE = 2,
	RED = 3,
	NONE = 99,
}

@onready var tiles_layer :TileMapLayer= $TileMapLayer
@onready var ability_highlight_layer :TileMapLayer= $AbilityHighlightLayer
@onready var threat_highlight_layer :TileMapLayer= $ThreatHighlightLayer
@onready var debug_highlight_layer :TileMapLayer= $DebugHighlightLayer
@onready var cursor_layer :TileMapLayer= $CursorLayer
@onready var prop_layer :TileMapLayer= $PropLayer
@onready var astar_grid = AStarGrid2D.new()

var threat_tiles:Array[Vector2i]= []
var highlight_tiles: Array[Vector2i]= []
var entity_tiles: Array[Vector2i]= []
var enemy_tiles: Array[Vector2i]= []
var ally_tiles: Array[Vector2i]= []

var is_ability_select = false

signal tile_selected(map_pos: Vector2i)

func _ready() -> void:
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.cell_size = tiles_layer.tile_set.tile_size
	astar_grid.region = tiles_layer.get_used_rect()
	astar_grid.update()
	tile_selected.connect(_on_tile_selected)
	WorldManager.grid = self

enum TILE_EXCLUDE_FLAGS{
	EXCLUDE_OBSTACLES = 1,
	EXCLUDE_ENEMIES = 2,
	EXCLUDE_ALLIES = 4,
}

var possible_tiles_cache:Dictionary = {}
func get_possible_tiles(exclude_flags:int=7):
	populate_entity_tiles()
	var tiles = tiles_layer.get_used_cells()
	var props = prop_layer.get_used_cells()
	
	astar_grid.fill_solid_region(astar_grid.region,false)
	if (exclude_flags & TILE_EXCLUDE_FLAGS.EXCLUDE_OBSTACLES) != 0:
		for prop_pos in props:
			tiles.erase(prop_pos)
			astar_grid.set_point_solid(prop_pos)
	
	if (exclude_flags & TILE_EXCLUDE_FLAGS.EXCLUDE_ENEMIES) != 0:
		for enemy_pos in enemy_tiles:
			var enemy_map_pos = prop_layer.local_to_map(enemy_pos)
			tiles.erase(enemy_map_pos)
			astar_grid.set_point_solid(enemy_map_pos)
			
	if (exclude_flags & TILE_EXCLUDE_FLAGS.EXCLUDE_ALLIES) != 0:
		for ally_pos in ally_tiles:
			var enemy_map_pos = prop_layer.local_to_map(ally_pos)
			tiles.erase(enemy_map_pos)
			astar_grid.set_point_solid(enemy_map_pos)
	
	return tiles
	
func set_highlight(map_position:Vector2i, color:HIGHLIGHT_COLORS,layer:HIGHLIGHT_LAYERS):
	var highlight_layer = get_highlight_layer(layer)
		
	if color == HIGHLIGHT_COLORS.NONE:
		highlight_tiles.erase(map_position)
		highlight_layer.erase_cell(map_position)
	else:
		highlight_tiles.push_front(map_position)
		highlight_layer.set_cell(map_position,0,Vector2i(color,0))

func set_highlight_area(
	map_area:Array[Vector2i], 
	color:HIGHLIGHT_COLORS=HIGHLIGHT_COLORS.GREEN,
	layer:HIGHLIGHT_LAYERS=HIGHLIGHT_LAYERS.DEBUG
):
	for map_position in map_area:
		var highlight_layer = get_highlight_layer(layer)
			
		if color == HIGHLIGHT_COLORS.NONE:
			highlight_tiles.erase(map_position)
			highlight_layer.erase_cell(map_position)
		else:
			highlight_tiles.push_front(map_position)
			highlight_layer.set_cell(map_position,0,Vector2i(color,0))


		
func clear_all_highlights(layer:HIGHLIGHT_LAYERS):
	var highlight_layer = get_highlight_layer(layer)
	highlight_layer.clear()

func get_highlight_layer(layer:HIGHLIGHT_LAYERS):
	var highlight_layer = ability_highlight_layer
	if layer == HIGHLIGHT_LAYERS.THREAT:
		highlight_layer = threat_highlight_layer
	elif layer == HIGHLIGHT_LAYERS.DEBUG:
		highlight_layer = debug_highlight_layer
	return highlight_layer
	
func get_manhattan_distance(a:Vector2,b:Vector2):
	var y_distance = Vector2(0,a.y).distance_to(Vector2(0,b.y))
	var x_distance = Vector2(a.x,0).distance_to(Vector2(b.x,0))
	return abs(y_distance) + abs(x_distance)

func get_grid_local_mouse_position()->Vector2:
	return prop_layer.get_local_mouse_position()
	
func get_map_mouse_position()->Vector2i:
	return prop_layer.local_to_map(prop_layer.get_local_mouse_position())
	
func is_within_range(a:Vector2,b:Vector2,_range:int) -> bool:
	return get_manhattan_distance(a,b) <= _range

func local_to_map(local_pos:Vector2)->Vector2i:
	return prop_layer.local_to_map(local_pos)

func map_to_local(map_pos:Vector2i)->Vector2:
	return prop_layer.map_to_local(map_pos)
	
func get_nearest_path(source:Vector2i,target:Vector2i, include_obstacles:bool=true)->Array[Vector2i]:
	get_possible_tiles(include_obstacles if 1 else 3)
	var path = WorldManager.grid.astar_grid.get_id_path(source, target)
	if path.size() > 0:
		path.remove_at(0)
	return path
	
func is_within_bounds(map_pos:Vector2i):
	var rect = tiles_layer.get_used_rect()
	return rect.has_point(map_pos)

func _on_tile_selected(map_pos:Vector2i):
	set_map_cursor(map_pos)
	
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
	entity_tiles = []
	enemy_tiles = []
	ally_tiles = []
	
	for entity in get_tree().get_nodes_in_group(C.GROUPS_ENTITIES):
		entity_tiles.push_front(entity.map_position)
		if entity.team == C.TEAM.ENEMY and WorldManager.team_turn == C.TEAM.PLAYER:
			enemy_tiles.push_front(entity.map_position)
		elif entity.team != C.TEAM.ENEMY and WorldManager.team_turn == C.TEAM.ENEMY:
			enemy_tiles.push_front(entity.map_position)
		elif entity.team == WorldManager.team_turn:
			ally_tiles.push_front(entity.map_position)
		