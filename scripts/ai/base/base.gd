extends Node

@onready var host:UnitEntity = self.get_parent()

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("action2")):
		find_target()	
		
func find_target():
	print("find_target")
	var used_cells = WorldManager.active_tilemap.get_used_cells()
	var local_pos = WorldManager.active_tilemap.local_to_map(host.position)
	var moveable_tiles = get_moveable_tiles(local_pos,host.move_range, used_cells)
	for tile in moveable_tiles:
		#WorldManager.active_tilemap.set_highlight(tile)
		var tile_value = get_tile_value(tile)
		if tile_value > 0:
			WorldManager.active_tilemap.set_highlight(tile)
			host.move_to(tile)
			print("tile ",tile)
			var tile_local_pos = WorldManager.active_tilemap.map_to_local(tile)
			var global_pos = WorldManager.active_tilemap.to_global(tile_local_pos)
			print("local ",tile_local_pos)
			print("global ",global_pos)
			host.move_to(global_pos)
		
func get_tile_value(tile_pos:Vector2)->int:
	var value = 0
	
	for ability in host.get_abilities():
		for target in get_tree().get_nodes_in_group(C.TARGETS):
			var target_map_pos = WorldManager.active_tilemap.local_to_map(target.position)
			var distance = tile_pos.distance_to(target_map_pos)
			if distance <= ability.range and distance != 0:
				value = +10
			#print('tile_pos - ',tile_pos,' target_pos - ',target_map_pos, ' distance - ',tile_pos.distance_to(target_map_pos))
	return value
		
		
		
func get_moveable_tiles(position:Vector2, range:int, used_cells:Array):
	var tiles = []
	print('range',range(range*-1, range+1, 1))
	for x in range(range*-1, range+1, 1):
		for y in range(range*-1, range+1, 1):
			#print('x,y,rec.x,rec.y','-',x+position.x,'-',y+position.y,'-',rec_bounds.x,'-',rec_bounds.y)
			if(used_cells.has(Vector2i(x+position.x, y+position.y))):
				tiles.append(Vector2(x,y) + position)
	return tiles
	
func find_target_test():
	for target in get_tree().get_nodes_in_group(C.TARGETS):
		target = target as Entity
		var target_pos = target.position
		var local_pos = WorldManager.active_tilemap.local_to_map(target_pos)
		
		print("target pos ", target_pos)
		WorldManager.active_highlight_tilemap.set_cell(local_pos,0,Vector2i(0,0))
