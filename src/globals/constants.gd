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

enum COLORS{
	GREEN,
	BLUE,
	CYAN,
	RED,
	ORANGE,
	YELLOW,
	PURPLE
}

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
	AI_RETREAT,
	AI_FARTHEST,
	AI_SPREAD,
	AI_TOGETHER
}

enum ORIENTATION{
	HORIZONTAL,
	VERTICAL
}

enum DIALOGUE_TRIGGER{
	ON_START
}

enum STRATEGIES{
	NEAREST,
	FARTHEST,
	RETREAT,
	SPREAD,
	TOGETHER
}

enum STATUS{
	HASTE
}

enum DIRECTION{
	NORTH,
	SOUTH,
	EAST,
	WEST
}

var DIRECTION_VECTORS={
	DIRECTION.NORTH:Vector2i(0,-1),
	DIRECTION.SOUTH:Vector2i(0,1),
	DIRECTION.WEST:Vector2i(-1,0),
	DIRECTION.EAST:Vector2i(1,0),
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
