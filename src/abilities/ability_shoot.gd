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
