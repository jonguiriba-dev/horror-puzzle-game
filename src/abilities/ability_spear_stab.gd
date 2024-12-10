extends Ability
class_name AbilitySpearStab
func _ready() -> void:
	super()
	texture = preload("res://assets/ui/ability_frame_spear_stab.png")
	ability_name = "spear_stab"
	ability_range = 2
	knockback_distance = 1
	damage = 1
	target_count = 2
	aoe_pattern = TilePattern.generate_directional_line_pattern
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
	SfxManager.play("hit-crunch-1")
