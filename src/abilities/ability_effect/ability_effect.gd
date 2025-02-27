extends Resource
class_name AbilityEffect

enum EFFECT_TYPES{
	DAMAGE,
	KNOCKBACK,
	PULL,
	MOVE,
	STATUS,
	SUMMON,
	SELF_DAMAGE
}

@export var effect_type:EFFECT_TYPES
@export var value := 0
@export var status_prop:StatusProps
@export var entity_type:=EntityManager.ENTITY_TYPES.NONE
