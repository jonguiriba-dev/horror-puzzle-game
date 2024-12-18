extends AbilityAnimation

static func play(host:Entity,target_map_position:Vector2i):
	SfxManager.play("charge-4")
	var charge_in_vfx = VfxManager.get_vfx_node("charge_in")
	host.get_parent().add_child( charge_in_vfx )
	var source_offset = Vector2(-15,-8)
	charge_in_vfx.position = host.position + source_offset
	charge_in_vfx.particles.one_shot = true
	charge_in_vfx.particles.restart()
	await charge_in_vfx.particles.finished
	
	var laser = VfxManager.get_vfx_node("laser")
	laser.position = host.position + source_offset
	host.get_parent().add_child( laser )
	
	var local_position = WorldManager.grid.map_to_local(target_map_position) + Vector2(0,-16)
	var global_position = Util.get_global_from_local(local_position,host.get_parent())
	
	laser.start(global_position)
	await laser.finished
	SfxManager.play("hit-2")
