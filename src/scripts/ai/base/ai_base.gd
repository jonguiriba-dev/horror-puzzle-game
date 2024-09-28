extends Node

@onready var host:Unit = self.get_parent()

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("action2")):
		find_target()	
		
func find_target():
	print("find_target")
	for tile in host.get_reachable_tiles(host.move_range):
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
			if distance <= ability.ability_range and distance != 0:
				value = +10
			#print('tile_pos - ',tile_pos,' target_pos - ',target_map_pos, ' distance - ',tile_pos.distance_to(target_map_pos))
	return value
		
		
		
	
func find_target_test():
	for target in get_tree().get_nodes_in_group(C.TARGETS):
		target = target as Entity
		var target_pos = target.position
		var local_pos = WorldManager.active_tilemap.local_to_map(target_pos)
		
		print("target pos ", target_pos)
		WorldManager.active_highlight_tilemap.set_cell(local_pos,0,Vector2i(0,0))
