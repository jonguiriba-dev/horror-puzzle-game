extends Node2D
class_name Grid

@onready var tiles_layer :TileMapLayer= $TileMapLayer
@onready var highlight_layer :TileMapLayer= $HighlightLayer
@onready var prop_layer :TileMapLayer= $PropLayer
@onready var astar_grid = AStarGrid2D.new()
var threat_tiles :Array[Vector2i]= []

enum HIGHLIGHT_COLORS{
	GREEN = 0,
	ORANGE = 1,
	BLUE = 2,
	RED = 3
}

func _ready() -> void:
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.cell_size = tiles_layer.tile_set.tile_size
	astar_grid.region = tiles_layer.get_used_rect()
	astar_grid.update()
	
	WorldManager.grid = self
	
func get_possible_tiles(include_obstacles:bool=true):
	var tiles = tiles_layer.get_used_cells()
	var props = prop_layer.get_used_cells()
	var enemies = get_tree().get_nodes_in_group(C.GROUPS.ENEMIES)
	
	if include_obstacles:
		for prop_pos in props:
			tiles.erase(prop_pos)
			astar_grid.set_point_solid(prop_pos)
	else:
		astar_grid.fill_solid_region(astar_grid.region,false)
		
	
	for enemy in enemies:
		var enemy_map_pos = prop_layer.local_to_map(enemy.position)
		tiles.erase(enemy_map_pos)
		astar_grid.set_point_solid(enemy_map_pos)
	
	return tiles

	
func set_highlight(map_position:Vector2, color:HIGHLIGHT_COLORS=HIGHLIGHT_COLORS.GREEN):
	highlight_layer.set_cell(map_position,0,Vector2i(color,0))
	
func clear_all_highlights():
	highlight_layer.clear()
	for node in get_tree().get_nodes_in_group(C.HIGHLIGHT_TEXT):
		node.queue_free()
		
func get_manhattan_distance(a:Vector2,b:Vector2):
	var y_distance = Vector2(0,a.y).distance_to(Vector2(0,b.y))
	var x_distance = Vector2(a.x,0).distance_to(Vector2(b.x,0))
	return abs(y_distance) + abs(x_distance)

func get_map_mouse_position()->Vector2i:
	return prop_layer.local_to_map(prop_layer.get_local_mouse_position())
	
func is_within_range(a:Vector2,b:Vector2,_range:int) -> bool:
	return get_manhattan_distance(a,b) <= _range

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		print("*Tile Position: ",WorldManager.grid.local_to_map(WorldManager.grid.prop_layer.get_local_mouse_position()))
			
func add_test(map_position:Vector2):
	prop_layer.set_cell(map_position,8,Vector2i(0,0))
	print("add_test",map_position)
	
	var sprite_pos = prop_layer.map_to_local(map_position)

	var offset_vector = Vector2(0,-12)
	var entity = preload("res://src/entities/entity/Entity.tscn").instantiate()
	entity.position = sprite_pos
	entity.sprite_texture = preload("res://assets/obstacle.png")
	add_child(entity)
	entity.sprite.offset = offset_vector
	entity.add_to_group(C.TARGETS)

func local_to_map(local_pos:Vector2)->Vector2i:
	return prop_layer.local_to_map(local_pos)

func map_to_local(map_pos:Vector2i)->Vector2:
	return prop_layer.map_to_local(map_pos)
	
func get_nearest_path(source:Vector2i,target:Vector2i, include_obstacles:bool=true)->Array[Vector2i]:
	get_possible_tiles(include_obstacles)
	var path := WorldManager.grid.astar_grid.get_id_path(source, target)
	if path.size() > 0:
		path.remove_at(0)
	return path
