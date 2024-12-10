extends Ability
class_name AbilityStrike
func _ready() -> void:
	super()
	texture = preload("res://assets/ui/ability_frame_sword_strike.png")
	ability_name = "strike"
	ability_range = 1
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

func _play_animation(target_map_position:Vector2i):
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
