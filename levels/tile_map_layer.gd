extends TileMapLayer
class_name CustomTileMapLayer

@onready var highlight_layer :TileMapLayer= $HighlightLayer

enum HIGHLIGHT_COLORS{
	GREEN = 0,
	ORANGE = 1,
	BLUE = 2,
	RED = 3
}

func add_test(map_position:Vector2):
	set_cell(map_position,8,Vector2i(0,0))
	print("add_test",map_position)
	
	var sprite_pos = map_to_local(map_position)

	var offset_vector = Vector2(0,-12)
	var entity = preload("res://entities/Entity/Entity.tscn").instantiate()
	entity.position = sprite_pos
	entity.sprite_texture = preload("res://assets/obstacle.png")
	add_child(entity)
	entity.sprite.offset = offset_vector
	entity.add_to_group(C.TARGETS)


func set_highlight(map_position:Vector2, color:HIGHLIGHT_COLORS=HIGHLIGHT_COLORS.GREEN):
	highlight_layer.set_cell(map_position,0,Vector2i(color,0))
	
func clear_all_highlights():
	highlight_layer.clear()
	
func get_manhattan_distance(a:Vector2,b:Vector2):
	var y_distance = Vector2(0,a.y).distance_to(Vector2(0,b.y))
	var x_distance = Vector2(a.x,0).distance_to(Vector2(b.x,0))
	return abs(y_distance) + abs(x_distance)

func get_map_mouse_position()->Vector2i:
	return local_to_map(get_local_mouse_position())
	
func is_within_range(a:Vector2,b:Vector2,range:int) -> bool:
	return get_manhattan_distance(a,b) <= range
