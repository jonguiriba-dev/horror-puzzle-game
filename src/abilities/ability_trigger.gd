extends Resource
class_name AbilityTrigger

enum SOURCE_TYPES{
	ABILITY,
	HOST
}

enum TARGET_TYPES{
	SELF,
}

@export var source := SOURCE_TYPES.ABILITY
@export var target := TARGET_TYPES.SELF
@export var key := ""
@export var value := 0
