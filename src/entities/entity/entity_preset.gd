extends Resource
class_name EntityPreset

var ability_file_path = "res://src/abilities"
var state_file_path = "res://src/components/state_machine/entity"

enum STATE_LISTS{
	PLAYER_STATES
}

@export_group("Stats")
@export var entity_name := ""
@export var health = 1
@export var move_range = 3
@export var team :C.TEAM = C.TEAM.PLAYER

@export_group("Nodes")
## Ability script file name
@export var ability_list:Array[String] = []

## States
@export var state_list:STATE_LISTS=STATE_LISTS.PLAYER_STATES

func get_abilities()->Array[Ability]:
	var abilities = []
	for ability in ability_list:
		abilities.push_front(load("%s/%s"%[ability_file_path,ability]).new())
	return abilities

func get_states()->Array[State]:
	var states = []
	for state in state_list:
		states.push_front(load("%s/%s"%[state_file_path,state]).new())
	return states

func get_payer_states():
	return [
		EntityIdleState.new(),
		EntitySelectedState.new(),
		EntityDoneState.new(),
		EntityTargetSelectState.new(),
	]
