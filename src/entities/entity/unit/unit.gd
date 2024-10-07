extends Entity
class_name Unit

func _ready() -> void:
	super()
	add_to_group(C.GROUPS.UNITS)

func highlight_moveable_tiles(_move_range:int):
	WorldManager.grid.clear_all_highlights()
	var moveable_tile_positions = get_moveable_tiles(_move_range)
	for pos in moveable_tile_positions:
		WorldManager.grid.set_highlight(pos, Grid.HIGHLIGHT_COLORS.BLUE)
		
func highlight_attack_range_tiles(attack_range):
	WorldManager.grid.clear_all_highlights()
	var moveable_tile_positions = get_reachable_tiles(attack_range)
	for pos in moveable_tile_positions:
		WorldManager.grid.set_highlight(pos,Grid.HIGHLIGHT_COLORS.ORANGE)

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

func get_moveable_tiles(_range:int):
	var navigatable_tiles = []
	var possible_tiles = WorldManager.grid.get_possible_tiles()
	var map_position = WorldManager.grid.local_to_map(position)
	
	var queued_tiles = [map_position]
	
	var step = 0
	while !queued_tiles.is_empty():
		var pending_tiles = queued_tiles.duplicate()
		queued_tiles = []
		for direction in [Vector2i(-1,0),Vector2i(1,0),Vector2i(0,-1),Vector2i(0,1)]:
			for pending_tile in pending_tiles:
				var next_tile = pending_tile + direction
				if possible_tiles.has(next_tile):
					navigatable_tiles.push_front(next_tile)
					queued_tiles.push_front(next_tile)
		step += 1
		if step == _range:
			break
	return navigatable_tiles

func show_move_range():
	highlight_moveable_tiles(move_range)
	UIManager.ui.set_context(self)
	add_to_group(C.GROUPS.TARGETTING_ENTITY)
