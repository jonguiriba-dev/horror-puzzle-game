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
			C.GROUPS_ENTITIES,
			AbilityAction.ABILITY_ACTION_TYPE.DAMAGE
		),
		AbilityAction.new(
			C.GROUPS_ENTITIES,
			AbilityAction.ABILITY_ACTION_TYPE.KNOCKBACK
		)
	]
