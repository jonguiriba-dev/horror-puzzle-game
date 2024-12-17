extends Node

enum PATTERNS{
	DIRECTIONAL_LINE,
	LINE,
	DIAMOND,
	POINT
}

func get_callable(pattern:PATTERNS):
	match pattern:
		PATTERNS.DIRECTIONAL_LINE: return generate_directional_line_pattern
		PATTERNS.LINE: return generate_line_pattern
		PATTERNS.DIAMOND: return generate_diamond_pattern
		PATTERNS.POINT: return generate_point_pattern

func generate_directional_line_pattern(map_pos:Vector2i,_range:int,direction:Vector2i=Vector2i.ZERO):
	var tiles:Array[Vector2i]= []
	
	for i in range(_range):
		tiles.push_front(map_pos + (direction * i))
		
	return tiles
	
func generate_line_pattern(map_pos:Vector2i,_range:int,direction:Vector2i=Vector2i.ZERO)->Array[Vector2i]:
	var tiles:Array[Vector2i]= []
	for x in range(_range*-1, _range+1):
		for y in range(_range*-1, _range+1):
			var next_position = Vector2i(x+map_pos.x, y+map_pos.y)
			if next_position.x != map_pos.x and next_position.y != map_pos.y:
				continue
			if abs(Util.get_manhattan_distance(map_pos,next_position)) <= _range:
					tiles.append(next_position)

	return tiles
	

func generate_diamond_pattern(map_pos:Vector2i,_range:int,direction:Vector2i=Vector2i.ZERO)->Array[Vector2i]:
	var tiles:Array[Vector2i]= []
	for x in range(_range*-1, _range+1):
		for y in range(_range*-1, _range+1):
			var next_position = Vector2i(x+map_pos.x, y+map_pos.y)
			if abs(Util.get_manhattan_distance(map_pos,next_position)) <= _range:
					tiles.append(next_position)

	return tiles

func generate_point_pattern(map_pos:Vector2i,_range:int,direction:Vector2i=Vector2i.ZERO)->Array[Vector2i]:
	return [map_pos]
