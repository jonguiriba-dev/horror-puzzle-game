extends Object
class_name AbilityAction

var target_group:String
var type:C.ABILITY_ACTION_TYPE

func _init(_target_group:String,_type:C.ABILITY_ACTION_TYPE) -> void:
	target_group = _target_group
	type = _type
