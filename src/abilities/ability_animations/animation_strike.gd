extends AbilityAnimation

static func play(host:Entity,target_map_position:Vector2i):
	var node = Node2D.new()
	host.get_parent().add_child(node)
	node.position = WorldManager.grid.map_to_local(target_map_position) 

	var options = {
		"source_position":host.map_position,
		"target_position":target_map_position,
	}
	
	await VfxManager.spawn("slash-1",node,options)

	SfxManager.play("hit-crunch-1")
	await Util.wait(0.1)
