extends TileMapLayer
class_name CustomTileMapLayer

@onready var highlight_layer := $HighlightLayer
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


func set_highlight(map_position:Vector2):
	highlight_layer.set_cell(map_position,0,Vector2i(0,0))
	
