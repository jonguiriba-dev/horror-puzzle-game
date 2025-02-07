extends Node

const STARTING_UNIT_PRESETS := [
	preload("res://src/entities/entity/presets/main_characters/elyana/elyana_preset.tres"),
	preload("res://src/entities/entity/presets/main_characters/layla/layla_preset.tres"),
	preload("res://src/entities/entity/presets/main_characters/talya/talya_preset.tres"),
	preload("res://src/entities/entity/presets/allies/knight/knight_preset.tres"),
	preload("res://src/entities/entity/presets/allies/knight/knight_preset.tres"),
	preload("res://src/entities/entity/presets/allies/knight/knight_preset.tres")
]

var units := []
var inventory := {
	"abilities": []
}
var gold := 0


func _ready() -> void:
	print("READY PLAYER MANAGER")
	if units == []:
		load_starting_units()

func load_starting_units():
	Util.sysprint("PlayerManager","loading starting units")
	units = []
	for starting_unit_preset in STARTING_UNIT_PRESETS:
		print("> ",starting_unit_preset)
		units.push_front(EntityManager.create_entity(starting_unit_preset))
		
func get_units_by_name(name:String):
	return units.filter(func(e): 
		if is_instance_valid(e) and e.entity_name == name:
			return e
	)
	
func add_entity_ability(entity:Entity,ability:AbilityProp):
	entity.add_ability(ability)

func add_gold(amount:int):
	gold += amount
