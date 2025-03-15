extends Resource
class_name AbilityEffect

enum EFFECT_TYPES{
	DAMAGE,
	KNOCKBACK,
	PULL,
	MOVE,
	STATUS,
	SUMMON,
	SELF_DAMAGE,
	CANCEL_THREAT,
	STAT_CHANGE
}

enum TAGS{
	SELF_DAMAGE,
	PASS_THROUGH,
}

@export var effect_type:EFFECT_TYPES
@export var value := 0
@export var status_type:=Status.STATUS_TYPES.NONE
@export var entity_type:=EntityManager.ENTITY_TYPES.NONE
@export var stat_key:String
@export_range(0.0, 1.0, 0.05) var success_rate:=1.0
@export var tags:Array[TAGS]
