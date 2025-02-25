extends Node


const GROUPS:={
	"ENTITIES":"entities",
	"ALLIES" : "allies",
	"UNITS":"units",
	"CIVILIANS":"civilians",
	"TARGETTING_ABILITY" : "targetting_ability",
	"HOVERED_ENTITIES" : "hovered_entities",
	"TARGETS" : "targets",
	"HIGHLIGHT_TEXT" : "highlight_text",
	"ENEMIES" : "enemies",
	"SELECTED" : "selected",
	"PLAYER_ENTITIES" : "player_entities",
	"ANIMATING_ENTITIES" : "animating_entities",
}
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
var GROUPS_ANIMATING_ENTITIES = "animating_entities"

#map
var GROUPS_HOVERED_REGIONS = "region_entered"

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
	AI_FORWARD,
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
	FORWARD,
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

const SCENES := {
	"LEVELS":{
		"CAVE":"res://src/levels/cave/Cave.tscn"
	},
	"UI":{
		"LEVEL":{
			"EVENT_OPTION":"res://src/levels/EventOption.tscn"
		}
	}
}

#func _ready() -> void:
	#preload("res://src/entities/entity/entity_data.gd")
	#preload("res://src/abilities/ability_prop.gd")
	#preload("res://src/abilities/ability_data.gd")
	#preload("res://src/abilities/ability_v2.gd")
	#
