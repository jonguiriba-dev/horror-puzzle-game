extends Resource
class_name AbilityEffect

enum EFFECT_TYPES{
	DAMAGE,
	KNOCKBACK,
	PULL,
	MOVE,
	STATUS,
	SUMMON
}

@export var effect_type:EFFECT_TYPES
@export var value := 0
@export var status_prop:StatusProps
@export var entity_type:EntityManager.ENTITY_TYPES

#func _init(_effect_type:EFFECT_TYPES, _value:int=0) -> void:
	#effect_type = _effect_type
	#value = _value
