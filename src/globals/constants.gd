extends Node

var GROUPS_ENTITIES = "entities"
var GROUPS_UNITS= "units"
var GROUPS_CIVILIANS= "civilians"
var GROUPS_TARGETTING_ENTITY = "targetting_entity"
var GROUPS_HOVERED_ENTITIES = "hovered_entities"
var GROUPS_TARGETS = "targets"
var GROUPS_HIGHLIGHT_TEXT = "highlight_text"
var GROUPS_ENEMIES = "enemies"
var GROUPS_SELECTED = "selected"

enum TEAM{
	PLAYER,
	ENEMY,
	CITIZEN,
	GUEST
}

enum STATE{
	ENTITY_IDLE,
	ENTITY_SELECTED,
	ENTITY_TARGET_SELECT,
	ENTITY_DONE,
	AI_ATTACK,
	AI_IDLE,
}

var ABILITY_TARGET_GROUP = {
	TILE = "target_group_tile"
}

enum ABILITY_ACTION_TYPE{
	DAMAGE,
	MOVE
}
