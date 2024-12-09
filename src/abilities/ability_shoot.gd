extends Ability
class_name AbilityShoot
func _ready() -> void:
	super()
	texture = preload("res://assets/ui/ability_frame_crossbow_shoot.png")
	ability_name = "shoot"
	ability_range = 5
	knockback_distance = 1
	damage = 1
	actions = [
		AbilityAction.new(
			AbilityAction.TARGET_TYPES.ENEMY,
			AbilityAction.ACTION_TYPES.DAMAGE
		),
		AbilityAction.new(
			AbilityAction.TARGET_TYPES.ENEMY,
			AbilityAction.ACTION_TYPES.KNOCKBACK
		)
	]
	range_pattern = TilePattern.generate_line_pattern

func _play_animation(target_map_position:Vector2i):
	#var projectile = Sprite2D.new()
	#projectile.texture = load("res://assets/fx/crossbow-bolt.png")
	#projectile.position = host.position + Vector2(10,-5)
	#projectile.z_index = 99
	#var direction = Util.get_direction(host.map_position, target_map_position)
	#
	#var target_offset = Vector2(-5,-15)
	#if direction.x == 0:
		#target_offset = Vector2(-5,-5)
		#if direction.y == 1:
			#projectile.rotate(90)
		#else:
			#projectile.rotate(-45)
	#WorldManager.grid.prop_layer.add_child(projectile)
	#
	SfxManager.play("charge-4")
	var charge_in_vfx = VfxManager.spawn("charge_in")
	host.get_parent().add_child( charge_in_vfx )
	var source_offset = Vector2(-15,-8)
	charge_in_vfx.position = host.position + source_offset
	charge_in_vfx.particles.one_shot = true
	charge_in_vfx.particles.restart()
	await charge_in_vfx.particles.finished
	
	var laser = VfxManager.spawn("laser")
	laser.position = host.position + source_offset
	host.get_parent().add_child( laser )
	
	var local_position = WorldManager.grid.map_to_local(target_map_position) + Vector2(0,-16)
	var global_position = Util.get_global_from_local(local_position,host.get_parent())
	
	laser.start(global_position)
	await laser.finished
	SfxManager.play("hit-2")

	#var tween = create_tween()
	
	#tween.tween_property(projectile, "position", WorldManager.grid.map_to_local(target_map_position) + target_offset, 0.3)
	#await tween.finished.connect(func():
		#projectile.queue_free()
	#)
	#
	
	
	#await Util.wait(0.1)
