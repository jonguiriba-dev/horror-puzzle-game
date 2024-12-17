extends Resource
class_name AbilityAction

enum ACTION_TYPES{
	DAMAGE,
	KNOCKBACK,
	MOVE
}

enum TARGET_TYPES{
	ENEMY = 1 << 0,
	ALLY = 1 << 1,
	TILE = 1 << 2,
}

@export var target_type:TARGET_TYPES=TARGET_TYPES.ENEMY
@export var action_type:ACTION_TYPES
@export var value := 0

func _init(_target_type:TARGET_TYPES,_action_type:ACTION_TYPES) -> void:
	target_type = _target_type
	action_type = _action_type
