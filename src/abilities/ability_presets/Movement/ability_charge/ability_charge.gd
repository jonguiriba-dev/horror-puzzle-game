extends Ability

func get_target_tiles(
	map_pos:Vector2i=host.map_position,
	_range:int=ability_range,
)->Array[Vector2i]:
	var target_tiles:Array[Vector2i] = super(map_pos,_range)
	var possible_tiles:Array[Vector2i] = []
	for tile in target_tiles:
		possible_tiles.push_front(tile + Util.get_direction(map_pos,tile))
			
	return possible_tiles.filter(func (e): return WorldManager.level.grid.is_empty_tile(e))
