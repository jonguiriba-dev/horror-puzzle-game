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
	match vfx_name:
		"hit-spark-1": 
			node = preload("res://src/components/objects/effects/hit_spark/HitSpark.tscn").instantiate()
		"slash-1": 
			node = preload("res://src/components/objects/effects/slash/Slash.tscn").instantiate()
		"spear-stab-1": 
			node = preload("res://src/components/objects/effects/spear_stab/SpearStab.tscn").instantiate()
	
	host.get_parent().add_child(node)
	node.position = host.position 
	if options.has("offset"):
		print(123,options)
		node.position += options.offset 
	
	node.animated_sprite.play()
	
	if options.has("source_position") and options.has("target_position"):
		var direction = Util.get_direction(options.source_position,options.target_position)
		print(">> direction",direction)
		if node.is_directional:
			match(direction):
				Util.DIRECTIONS.NORTH: 
					node.animated_sprite.flip_h = false
					node.animated_sprite.flip_v = true
				Util.DIRECTIONS.EAST: 
					node.animated_sprite.flip_h = false
					node.animated_sprite.flip_v = false
				Util.DIRECTIONS.WEST: 
					node.animated_sprite.flip_h = true
					node.animated_sprite.flip_v = true
				Util.DIRECTIONS.SOUTH: 
					node.animated_sprite.flip_h = true
					node.animated_sprite.flip_v = false
		
	await node.animated_sprite.animation_finished
	
	node.queue_free()
	
func flash(item:CanvasItem, color:Color, time:float):
	var prev_modulate = item.modulate
	var tween = create_tween()
	tween.tween_property(item, "modulate", color, time)
	tween.tween_property(item, "modulate", prev_modulate, time)
	
	
