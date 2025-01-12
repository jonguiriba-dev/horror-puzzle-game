extends AbilityAnimation

static func play(host:Entity,target_map_position:Vector2i):
	var node = Node2D.new()
	host.get_parent().add_child(node)
	
	var direction = Util.get_direction(host.map_position,target_map_position)
	node.position = WorldManager.level.grid.map_to_local(host.map_position + direction) 
	
	var options = {
		"source_position":host.map_position,
		"target_position":target_map_position,
	}
	VfxManager.spawn("spear-stab-1",node,options)
	node.queue_free()
	SfxManager.play("hit-crunch-1")
