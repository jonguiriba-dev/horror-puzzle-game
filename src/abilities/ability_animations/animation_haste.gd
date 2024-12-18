extends AbilityAnimation

static func play(host:Entity,target_map_position:Vector2i):
	VfxManager.spawn("charge-in-1",host,{"offset":Vector2(10,-20)})
	SfxManager.play("grunt-girl-1")
	
