extends TileMapLayer
class_name CustomTileMapLayer

@onready var highlight_layer :TileMapLayer= $HighlightLayer
@onready var prop_layer :TileMapLayer= $PropLayer
@onready var astar_grid = AStarGrid2D.new()

enum HIGHLIGHT_COLORS{
	GREEN = 0,
	ORANGE = 1,
	BLUE = 2,
	RED = 3
}

func _ready() -> void:
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.cell_size = tile_set.tile_size
	astar_grid.region = get_used_rect()
	astar_grid.update()

func get_pathable_tiles():
	var tiles = get_used_cells()
	var props = prop_layer.get_used_cells()
	var enemies = get_tree().get_nodes_in_group(C.GROUPS_ENEMIES)
	
	for prop_pos in props:
		tiles.erase(prop_pos)
		astar_grid.set_point_solid(prop_pos)
	for enemy in enemies:
		var enemy_map_pos = local_to_map(enemy.position)
		tiles.erase(enemy_map_pos)
		astar_grid.set_point_solid(enemy_map_pos)
	
	return tiles

	
func set_highlight(map_position:Vector2, color:HIGHLIGHT_COLORS=HIGHLIGHT_COLORS.GREEN):
	highlight_layer.set_cell(map_position,0,Vector2i(color,0))
	
func clear_all_highlights():
	highlight_layer.clear()
	for node in get_tree().get_nodes_in_group(C.HIGHLIGHT_TEXT):
		node.queue_free()
		

func get_map_mouse_position()->Vector2i:
	return local_to_map(get_local_mouse_position())
	
func is_within_range(a:Vector2,b:Vector2,range:int) -> bool:
	return Util.get_manhattan_distance(a,b) <= range
		
			
func add_test(map_position:Vector2):
	set_cell(map_position,8,Vector2i(0,0))
	print("add_test",map_position)
	
	var sprite_pos = map_to_local(map_position)

	var offset_vector = Vector2(0,-12)
	var entity = preload("res://src/entities/entity/Entity.tscn").instantiate()
	entity.position = sprite_pos
	add_child(entity)
	entity.sprite.offset = offset_vector
	entity.add_to_group(C.TARGETS)
