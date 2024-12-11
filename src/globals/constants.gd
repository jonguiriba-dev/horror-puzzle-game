extends Node

var GROUPS_ENTITIES = "entities"
var GROUPS_ALLIES = "allies"
var GROUPS_UNITS= "units"
var GROUPS_CIVILIANS= "civilians"
var GROUPS_TARGETTING_ABILITY = "targetting_ability"
var GROUPS_HOVERED_ENTITIES = "hovered_entities"
var GROUPS_TARGETS = "targets"
var GROUPS_HIGHLIGHT_TEXT = "highlight_text"
var GROUPS_ENEMIES = "enemies"
var GROUPS_SELECTED = "selected"
var GROUPS_PLAYER_ENTITIES = "player_entities"
var GROUPS_ANIMATING_ENTITIES = "animating_entities"


enum TEAM{
	PLAYER,
	ENEMY,
	CITIZEN,
	GUEST,
	ALLY
}

enum STATE{
	ENTITY_IDLE,
	ENTITY_SELECTED,
	ENTITY_TARGET_SELECT,
	ENTITY_DONE,
	AI_ATTACK,
	AI_IDLE,
}

enum ORIENTATION{
	HORIZONTAL,
	VERTICAL
}

enum DIALOGUE_TRIGGER{
	ON_START
}


var ABILITY_target_type = {
	TILE = "target_type_tile"
}

var ALLIED_TEAMS = {
	PLAYER = [C.TEAM.PLAYER, C.TEAM.ALLY, C.TEAM.CITIZEN],	
	ALLY = [C.TEAM.PLAYER, C.TEAM.ALLY, C.TEAM.CITIZEN],	
	CITIZEN = [C.TEAM.PLAYER, C.TEAM.ALLY, C.TEAM.CITIZEN],	
	ENEMY = [],	
}
