extends Ability
class_name AbilityMove

func _ready() -> void:
	super()
	highlight_color = Color.GREEN
	has_ui = false
	ability_name = "move"
	ability_range = 3
	actions = [
		AbilityAction.new(
			C.ABILITY_TARGET_GROUP.TILE,
			C.ABILITY_ACTION_TYPE.MOVE
		)
	]
