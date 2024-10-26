extends Node

func generate_line_pattern(map_pos:Vector2i,_range:int)->Array[Vector2i]:
	var tiles:Array[Vector2i]= []
	for x in range(_range*-1, _range+1):
		for y in range(_range*-1, _range+1):
			var next_position = Vector2i(x+map_pos.x, y+map_pos.y)
			if next_position.x != map_pos.x and next_position.y != map_pos.y:
				continue
			if abs(Util.get_manhattan_distance(map_pos,next_position)) <= _range:
					tiles.append(next_position)

	return tiles
	

func generate_diamond_pattern(map_pos:Vector2i,_range:int)->Array[Vector2i]:
	var tiles:Array[Vector2i]= []
	for x in range(_range*-1, _range+1):
		for y in range(_range*-1, _range+1):
			var next_position = Vector2i(x+map_pos.x, y+map_pos.y)
			if abs(Util.get_manhattan_distance(map_pos,next_position)) <= _range:
					tiles.append(next_position)

	return tiles
