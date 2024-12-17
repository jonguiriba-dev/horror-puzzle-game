extends Ability
class_name AbilitySpearStab
func _ready() -> void:
	super()
	texture = preload("res://assets/ui/ability_frame_spear_stab.png")
	ability_name = "Spear Stab"
	ability_range = 2
	knockback_distance = 1
	damage = 1
	aoe_pattern = TilePattern.PATTERNS.DIRECTIONAL_LINE
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
	range_pattern = TilePattern.PATTERNS.LINE
	use_host_as_origin = true

func _play_animation(target_map_position:Vector2i):
	var node = Node2D.new()
	host.get_parent().add_child(node)
	
	var direction = Util.get_direction(host.map_position,target_map_position)
	node.position = WorldManager.grid.map_to_local(host.map_position + direction) 
	
	
	var options = {
		"source_position":host.map_position,
		"target_position":target_map_position,
	}
	VfxManager.spawn("spear-stab-1",node,options)
	node.queue_free()
	SfxManager.play("hit-crunch-1")
