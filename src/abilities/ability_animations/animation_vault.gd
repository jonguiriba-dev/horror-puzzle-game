extends AbilityAnimation

static func play(host:Entity,target_map_position:Vector2i):
	AnimationManager.jump(host,WorldManager.level.grid.map_to_local(target_map_position))
	SfxManager.play("grunt-girl-1")
