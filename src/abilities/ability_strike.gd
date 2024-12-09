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
	SfxManager.play("hit-crunch-1")
	await Util.wait(0.1)
