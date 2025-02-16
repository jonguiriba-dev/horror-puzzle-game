extends Resource
class_name SaveData


@export var player_manager := {}
@export var scene_manager := {}
@export var level := {}
@export var map := {}

func to_dict()->Dictionary:
	return {
		"player_manager":player_manager,
		"scene_manager":scene_manager,
		"level":level,
		"map":map,
	}

func reset():
	player_manager = {}
	scene_manager = {}
	level = {}
	map = {}
