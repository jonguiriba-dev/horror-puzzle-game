extends Node

#groups
var ENTITIES = "entities"
var HOVERED_ENTITIES = "hovered_entities"
var TARGETS = "targets"
var HIGHLIGHT_TEXT = "highlight_text"

var GROUPS = {
	ENTITIES = "entities",
	UNITS= "units",
	CIVILIANS= "civilians",
	TARGETTING_ENTITY = "targetting_entity",
	HOVERED_ENTITIES = "hovered_entities",
	TARGETS = "targets",
	HIGHLIGHT_TEXT = "highlight_text",
	ENEMIES = "enemies",
	SELECTED = "selected"
}


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
}

var ABILITY_TARGET_GROUP = {
	ENTITY = "target_group_entity",
	TILE = "target_group_tile"
}

enum ABILITY_ACTION_TYPE{
	DAMAGE,
	MOVE
}
