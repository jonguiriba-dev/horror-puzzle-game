extends Node

func get_vfx_node(vfx_name:String):
	match vfx_name:
		"charge_in": return preload("res://src/components/objects/effects/charge_in/ChargeIn.tscn").instantiate()
		"laser": return preload("res://src/components/objects/effects/laser/Laser.tscn").instantiate()
		"hit": return preload("res://src/components/objects/effects/hit/Hit.tscn").instantiate()
		"hit-spark-1": 
			return preload("res://src/components/objects/effects/hit_spark/HitSpark.tscn").instantiate()

func spawn(vfx_name:String,host:Node2D,options:Dictionary={}):
	
	var node:Vfx
	var wait_time
	match vfx_name:
		"charge-in-1": 
			node = preload("res://src/components/objects/effects/charge_in/ChargeIn.tscn").instantiate()
			wait_time = 1
		"hit-spark-1": 
			node = preload("res://src/components/objects/effects/hit_spark/HitSpark.tscn").instantiate()
		"slash-1": 
			node = preload("res://src/components/objects/effects/slash/Slash.tscn").instantiate()
		"spear-stab-1": 
			node = preload("res://src/components/objects/effects/spear_stab/SpearStab.tscn").instantiate()
	
	host.get_parent().add_child(node)
	node.position = host.position 
	if options.has("offset"):
		node.position += options.offset 

	if node.animated_sprite:
		await _play_animated_sprite(node,options)
	elif node.particles:
		await Util.wait(wait_time)
	node.queue_free()

func _play_animated_sprite(vfx,options:Dictionary):
	vfx.animated_sprite.play()
	if options.has("source_position") and options.has("target_position"):
		var direction = Util.get_direction(options.source_position,options.target_position)
		if vfx.is_directional:
			match(direction):
				Util.DIRECTIONS.NORTH: 
					vfx.animated_sprite.flip_h = false
					vfx.animated_sprite.flip_v = true
				Util.DIRECTIONS.EAST: 
					vfx.animated_sprite.flip_h = false
					vfx.animated_sprite.flip_v = false
				Util.DIRECTIONS.WEST: 
					vfx.animated_sprite.flip_h = true
					vfx.animated_sprite.flip_v = true
				Util.DIRECTIONS.SOUTH: 
					vfx.animated_sprite.flip_h = true
					vfx.animated_sprite.flip_v = false
		
	await vfx.animated_sprite.animation_finished

func flash(item:CanvasItem, color:Color, time:float):
	var prev_modulate = item.modulate
	var tween = create_tween()
	tween.tween_property(item, "modulate", color, time)
	tween.tween_property(item, "modulate", prev_modulate, time)
	tween.tween_property(item, "modulate", color, time)
	tween.tween_property(item, "modulate", prev_modulate, time)
	
	
