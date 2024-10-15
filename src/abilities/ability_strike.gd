extends Ability
class_name AbilityStrike
func _ready() -> void:
	super()
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
