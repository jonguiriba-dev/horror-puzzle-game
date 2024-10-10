extends Entity
class_name Unit

func _ready() -> void:
	super()
	add_to_group(C.GROUPS_UNITS)


func get_reachable_tiles(_range:int):
	var possible_tiles = WorldManager.grid.get_possible_tiles()
	var map_position = WorldManager.grid.local_to_map(position)
	
	var tiles = []
	for x in range(_range*-1, _range+1, 1):
		for y in range(_range*-1, _range+1, 1):
			var next_position = Vector2i(x+map_position.x, y+map_position.y)
			if(possible_tiles.has(next_position) and
			 WorldManager.grid.get_manhattan_distance(map_position,next_position) <= _range ):
				tiles.append(next_position)
	return tiles
