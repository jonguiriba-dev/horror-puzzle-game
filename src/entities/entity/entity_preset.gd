extends Resource
class_name EntityPreset

var ability_file_path = "res://src/abilities"
var state_file_path = "res://src/components/state_machine/entity"

enum STATE_LISTS{
	PLAYER_STATES
}

@export_group("Stats")
@export var entity_name := ""
@export var max_health = 1
@export var move_range = 3
@export var team :C.TEAM = C.TEAM.PLAYER

@export_group("Nodes")
## Ability script file name
@export_file() var ability_1
@export_file() var ability_2
@export_file() var ability_3
@export_file() var ability_4

## States
@export_file() var state_machine

@export_group("Resources")
@export var sprite_frames:SpriteFrames

func get_abilities()->Array:
	var abilities = []
	for ability in [ability_1,ability_2,ability_3,ability_4]:
		if ability:
			abilities.push_front(load(ability).new())
	return abilities 

func get_state_machine()->StateMachine:
	return load(state_machine).instantiate()
