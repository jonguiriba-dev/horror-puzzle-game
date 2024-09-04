extends Node2D

@onready var tilemap : TileMapLayer = $"TileMapLayer"

func _ready() -> void:
	tilemap.set_cell(Vector2i(0,0),8,Vector2i(0,0))
	
func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("click")):
		var mouse_pos = tilemap.get_local_mouse_position()
		var local_pos = tilemap.local_to_map(mouse_pos)
		print("local_pos ",local_pos)
		tilemap.set_cell(local_pos,8,Vector2i(0,0))
		
		print("tilemap.tile_set.tile_size.x ",tilemap.tile_set.tile_size.x)
	
		#var sprite_pos = Vector2(tilemap.tile_set.tile_size.x * local_pos.x	,tilemap.tile_set.tile_size.y* local_pos.y)
		var sprite_pos = tilemap.map_to_local(local_pos)
		var offset_vector = Vector2(0,-12)
		var sprite = Sprite2D.new()
		sprite.position = sprite_pos + offset_vector
		sprite.texture = preload("res://assets/player.png")
		tilemap.add_child(sprite)
