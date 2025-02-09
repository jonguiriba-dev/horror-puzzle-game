extends Resource
class_name EntityData

var ability_file_path = "res://src/abilities"
var state_file_path = "res://src/components/state_machine/entity"

enum STATE_LISTS{
	PLAYER_STATES
}

@export_group("Stats")
@export var entity_name := ""
@export var max_health := 1
@export var move_range := 3
@export var team :C.TEAM = C.TEAM.PLAYER
@export var speed := 5
@export var max_move_counter := 1
@export var max_action_counter := 1
@export var max_ability_slots := 1
@export var max_equipment_slots := 2
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

var health := 1
var experience := 0
var lvl := 1
#var animation_counter := 0
var action_counter := 1
var move_counter := 1

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

func apply(entity:Entity):
	Util.sysprint("Entity:loading_preset", "loading_preset")
	if entity.data == null:
		entity.data = EntityData.new()
	
	entity.data.entity_name = entity_name
	entity.data.team = team
	entity.data.move_range = move_range
	entity.data.speed = speed
	entity.data.max_move_counter = max_move_counter
	entity.data.max_action_counter = max_action_counter
	entity.data.max_ability_slots = max_ability_slots
	entity.data.max_equipment_slots = max_equipment_slots
	entity.set_max_health(max_health)
	entity.preset = self

	for ability in get_abilities():
		entity.add_child(ability)
	
	entity.add_child(get_state_machine())
	

func apply_node_data(entity:Entity):
	entity.healthbar.max_value = max_health
	entity.healthbar.value = entity.data.health
	if sprite_frames:
		entity.sprite.sprite_frames = sprite_frames
	
	if portrait_image:
		entity.data.portrait_image = load(portrait_image)
	
	entity.sprite.position += sprite_offset
	entity.shadow.position += shadow_offset
