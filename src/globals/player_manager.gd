extends Node

#const STARTING_UNIT_PRESETS :Array[EntityData]= [
	#preload("res://src/entities/entity/presets/main_characters/elyana/elyana_preset.tres"),
	#preload("res://src/entities/entity/presets/main_characters/layla/layla_preset.tres"),
	#preload("res://src/entities/entity/presets/main_characters/talya/talya_preset.tres"),
	#preload("res://src/entities/entity/presets/allies/knight/knight_preset.tres"),
	#preload("res://src/entities/entity/presets/allies/knight/knight_preset.tres"),
	#preload("res://src/entities/entity/presets/allies/knight/knight_preset.tres")
#]
const STARTING_UNIT_PRESETS :Array[EntityData]= [
	preload("res://src/entities/entity/presets/allies/archer/archer_preset.tres"),
	preload("res://src/entities/entity/presets/allies/engineer/engineer_preset.tres"),
	preload("res://src/entities/entity/presets/allies/mage/mage_preset.tres"),
	preload("res://src/entities/entity/presets/allies/blade_master/blade_master_preset.tres"),
	preload("res://src/entities/entity/presets/allies/knight/knight_preset.tres"),
	preload("res://src/entities/entity/presets/allies/knight/knight_preset.tres"),
	#preload("res://src/entities/entity/presets/allies/knight/knight_preset.tres")
]
var units := []
var inventory := {
	"abilities": []
}
var gold := 0


func _ready() -> void:
	print("READY PLAYER MANAGER")
	WorldManager.level_complete.connect(_on_world_manager_level_complete)
	SaveManager.game_loaded.connect(_on_game_loaded)
	PlayerManager.load_starting_units()

func load_starting_units():
	Util.sysprint("PlayerManager","loading starting units")
	units = []
	for starting_unit_preset in STARTING_UNIT_PRESETS:
		print("> ",starting_unit_preset)
		units.push_front(EntityManager.create_entity(starting_unit_preset))
	SaveManager.save_data("player_manager",to_save_data())	
	SaveManager.save_game()	

func get_units_by_name(entity_name:String):
	return units.filter(func(e): 
		if is_instance_valid(e) and e.data.entity_name == entity_name:
			return e
	)
	
func add_entity_ability(entity:Entity,ability:AbilityData):
	#entity.add_ability(ability)
	pass

func add_gold(amount:int):
	gold += amount



func to_save_data():
	return {
		"gold":gold,
		"units":units.map(func(e):return e.to_save_data()),
		"inventory":{}
	}

func _on_game_loaded():
	print("load player manager")
	var load_data = SaveManager.get_loaded("player_manager")
	var loaded_units = load_data.get("units",[])
	print("loaded_units ",loaded_units)
	if load_data:
		units = loaded_units.map(func (e):
			return Entity.load_data(e)
		)
		inventory = load_data.inventory
		gold = load_data.gold
	
func _on_world_manager_level_complete() -> void:
	SaveManager.save_data("player_manager",to_save_data())	
	SaveManager.save_game()	
