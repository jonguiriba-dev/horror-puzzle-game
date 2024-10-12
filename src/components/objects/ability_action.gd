extends Object
class_name AbilityAction

enum ABILITY_ACTION_TYPE{
	DAMAGE,
	KNOCKBACK,
	MOVE
}


var target_group:String
var type:ABILITY_ACTION_TYPE

func _init(_target_group:String,_type:ABILITY_ACTION_TYPE) -> void:
	target_group = _target_group
	type = _type
