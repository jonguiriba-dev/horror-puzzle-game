extends Node2D
class_name World


func _ready() -> void:
	UIManager.initialize()
	
func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("click")):
		pass
	
		
		#WorldManager.grid.set_cell(local_pos,8,Vector2i(0,0))
		#
		#print("WorldManager.grid.tile_set.tile_size.x ",WorldManager.grid.tile_set.tile_size.x)
	#
		##var sprite_pos = Vector2(WorldManager.grid.tile_set.tile_size.x * local_pos.x	,WorldManager.grid.tile_set.tile_size.y* local_pos.y)
		#var sprite_pos = WorldManager.grid.map_to_local(local_pos)
		#var offset_vector = Vector2(0,-12)
		#var entity = preload("res://entities/Entity/Entity.tscn").instantiate()
		#entity.position = sprite_pos
		#entity.sprite_texture = preload("res://assets/obstacle.png")
		#WorldManager.grid.add_child(entity)
		#
		#entity.add_to_group(C.TARGETS)




# values for each bit flag
#const RIGHT: = 1
#const LEFT: = 2
#const UP: = 4
#const DOWN: = 8
#
#var flags: = 0
#flags |= RIGHT	# OR set unconditionally
#flags &= ~LEFT	# AND with NOT to unconditionally remove
#
## if same flag is set you get that value. Non 0 value is true
#if (flags & UP):    # (6 & 4) > 0 == (4) > 0
	#print("Success")
