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
	SaveManager.game_loaded.connect(_on_game_loaded)
	if units == []:
		load_starting_units()

func load_starting_units():
	Util.sysprint("PlayerManager","loading starting units")
	units = []
	for starting_unit_preset in STARTING_UNIT_PRESETS:
		print("> ",starting_unit_preset)
		units.push_front(EntityManager.create_entity(starting_unit_preset))
		
func get_units_by_name(entity_name:String):
	return units.filter(func(e): 
		if is_instance_valid(e) and e.data.entity_name == entity_name:
			return e
	)
	
func add_entity_ability(entity:Entity,ability:AbilityProp):
	entity.add_ability(ability)

func add_gold(amount:int):
	gold += amount

func save_data_to_storage():
	var savedata = to_save_data()
	print("savedata",savedata)
	SaveManager.save_data("player_manager",to_save_data())	
	SaveManager.save_game()	

func to_save_data():
	return {
		"gold":gold,
		"units":units.map(func(e):return e.to_save_data()),
		"inventory":{}
	}

func _on_game_loaded():
	print("load player manager")
	var load_data = SaveManager.get_loaded("player_manager")
	var loaded_units = load_data.units.map(func(e):return EntityManager.load_entity(e))
	print("loaded_units ",loaded_units)
	if load_data:
		units = loaded_units
		inventory = load_data.inventory
		gold = load_data.gold
	
