extends AbilityAnimation

static var animation_speed := 0.1

static func play(host:Entity,target_map_position:Vector2i):
	var path = WorldManager.level.grid.astar_grid.get_id_path(
			host.map_position, 
			target_map_position
		)
	if path.size() > 0:
		path.remove_at(0)
		path = path.filter(func(e):
			for ally in host.get_allies():
				if WorldManager.level.grid.local_to_map(ally.position) == e:
					return false
			return true
		)
	
	var tween = host.create_tween()
	
	for tile in path:
		tween.tween_property(
			host,
			"position",
			WorldManager.level.grid.map_to_local(tile),
			animation_speed
		)	
		#tween.tween_interval(0.05)
	tween.play()
	SfxManager.play("step-2")
	await tween.finished
	host.data.move_counter -= 1
