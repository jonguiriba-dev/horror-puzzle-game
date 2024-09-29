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
	
}

#team
enum TEAM{
	PLAYER,
	ENEMY,
	CITIZEN,
	GUEST
}
