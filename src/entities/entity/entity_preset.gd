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
@export var ability_props:Array[AbilityProp]
## States
@export_file() var state_machine

@export_group("Visual")
@export() var shadow_offset:Vector2
@export() var sprite_offset:Vector2

@export_group("Etc")
@export var sprite_frames:SpriteFrames
@export_file() var portrait_image


func get_abilities()->Array:
	var abilities = []
	for ability_prop in ability_props:
		var ability_node 
		if ability_prop.custom_ability_script:
			ability_node = load(ability_prop.custom_ability_script).new()
		else:
			ability_node = Ability.new()
		ability_node.ability_props = ability_prop
		abilities.push_front(ability_node)
	return abilities 

func get_state_machine()->StateMachine:
	return load(state_machine).instantiate()
