extends Ability
class_name AbilitySpearStab
func _ready() -> void:
	super()
	texture = preload("res://assets/ui/ability_frame_spear.png")
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
