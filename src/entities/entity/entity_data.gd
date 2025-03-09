extends Resource
class_name EntityData

const ENTITY_TSCN := preload("res://src/entities/entity/Entity.tscn") 

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
@export var starting_abilities:Array[AbilityData]
## States
@export_file() var state_machine

@export_group("Visual")
@export() var shadow_offset:Vector2
@export() var sprite_offset:Vector2

@export_group("Etc")
@export var sprite_frames:SpriteFrames
@export_file() var portrait_image

@export_group("Private")
@export var health := 1
@export var experience := 0
@export var lvl := 1
@export var action_counter := 1
@export var move_counter := 1
@export var abilities:Array[AbilityV2]=[]
	
func get_abilities()->Array[AbilityV2]:
	return abilities 

func apply_as_preset(entity:Entity):
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

	for starting_ability_data in starting_abilities:
		var ability = AbilityV2.new()
		if starting_ability_data.custom_ability_script:
			ability = load(starting_ability_data.custom_ability_script).new()
		ability.data = starting_ability_data.duplicate()
		entity.data.abilities.push_front(ability) 
	
	entity.set_max_health(max_health)
	entity.preset = self

	entity.data.state_machine = state_machine
	if state_machine:
		entity.add_child(load(state_machine).instantiate())


func apply_node_data(entity:Entity):
	if entity.data == null:
		apply_as_preset(entity)
	
	entity.healthbar.max_value = max_health
	entity.healthbar.value = entity.data.health
	if sprite_frames:
		entity.sprite.sprite_frames = sprite_frames
	
	if portrait_image:
		entity.data.portrait_image = load(portrait_image)
	
	entity.sprite.position += sprite_offset
	entity.shadow.position += shadow_offset

func to_save_data():
	var res = self.duplicate(true)
	return res
	
func load_data(entity:Entity):
	for ability in abilities:
		ability.setup(entity)
